import { Injectable, HttpException, HttpStatus } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { ConfigService } from '@nestjs/config';
import { firstValueFrom } from 'rxjs';

export interface FoodNutrition {
  fdsId: string;
  description: string;
  caloriesPer100g: number;
  protein: number;
  carbs: number;
  fat: number;
}

@Injectable()
export class FoodSearchService {
  private readonly usda_api_url = 'https://api.nal.usda.gov/fdc/v1/foods/search';
  private readonly cache = new Map<string, { data: FoodNutrition[]; timestamp: number }>();
  private readonly CACHE_TTL = 3600000; // 1 hour in milliseconds

  constructor(
    private httpService: HttpService,
    private configService: ConfigService,
  ) {}

  async searchFoods(query: string, limit: number = 10, isBranded: string = 'false'): Promise<FoodNutrition[]> {
    const cacheKey = `${query}:${limit}:${isBranded}`;
    const cached = this.cache.get(cacheKey);

    if (cached && Date.now() - cached.timestamp < this.CACHE_TTL) {
      return cached.data;
    }

    const apiKey = this.configService.get<string>('USDA_API_KEY');

    if (!apiKey) {
      throw new HttpException(
        'USDA API key not configured',
        HttpStatus.INTERNAL_SERVER_ERROR,
      );
    }

    const dataTypes = isBranded === 'true' 
      ? ['Branded']
      : ['Foundation', 'SR Legacy'];

    try {
      const response = await firstValueFrom(
        this.httpService.get<any>(this.usda_api_url, {
          params: {
            query,
            pageSize: limit,
            api_key: apiKey,
            dataType: dataTypes,
          },
        }),
      );

      const foods = response.data.foods || [];
      const results = foods
        .map((food) => this.extractNutrition(food))
        .filter((food): food is FoodNutrition => food !== null);

      this.cache.set(cacheKey, { data: results, timestamp: Date.now() });
      return results;
    } catch (e) {
      const error = e as any;
      const statusCode = error.response?.status;
      const message = error.response?.data?.message || error.message;

      if (statusCode === 429) {
        throw new HttpException(
          'API rate limit exceeded. Please try again later.',
          HttpStatus.TOO_MANY_REQUESTS,
        );
      }

      if (statusCode === 401) {
        throw new HttpException(
          'Invalid USDA API key',
          HttpStatus.INTERNAL_SERVER_ERROR,
        );
      }

      throw new HttpException(
        `Failed to search foods: ${message}`,
        statusCode || HttpStatus.BAD_REQUEST,
      );
    }
  }

  private extractNutrition(food: any): FoodNutrition | null {
    try {
      if (!food || !food.foodNutrients) {
        return null;
      }

      const nutrients = food.foodNutrients as any[];
      const servingSize = food.servingSize || 100;

      const getNutrient = (nutrientId: number): number => {
        const nutrient = nutrients.find((n) => n.nutrientId === nutrientId);
        return nutrient?.value || 0;
      };

      const calories = getNutrient(1008); // Energy (kcal)

      if (calories <= 0) {
        return null;
      }

      const protein = getNutrient(1003); // Protein
      const carbs = getNutrient(1005); // Carbohydrate
      const fat = getNutrient(1004); // Total lipid (fat)

      return {
        fdsId: food.fdcId?.toString() || '',
        description: (food.description || 'Unknown').substring(0, 200),
        caloriesPer100g: Math.round(calories * 10) / 10,
        protein: Math.round(protein * 10) / 10,
        carbs: Math.round(carbs * 10) / 10,
        fat: Math.round(fat * 10) / 10,
      };
    } catch (error) {
      return null;
    }
  }
}


