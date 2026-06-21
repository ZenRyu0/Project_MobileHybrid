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
  private readonly usda_api_url = 'https://api.nal.usda.gov/fdc/v1/foods/search'
  private readonly cache = new Map<string, { data: FoodNutrition[]; timestamp: number }>();
  private readonly CACHE_TTL = 3600000; 
  constructor(
    private httpService: HttpService,
    private configService: ConfigService,
  ) {}
  async searchFoods(query: string, limit: number = 10, isBranded: boolean = false): Promise<FoodNutrition[]> {
    const cacheKey = `${query}:${limit}:${isBranded}`;
    const cached = this.cache.get(cacheKey);
    const dataType = isBranded ? 'Branded' : 'Foundation,SR Legacy';
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
    if (apiKey === 'demo') {
      const mockResults: FoodNutrition[] = [
        {
          fdsId: 'demo-1',
          description: `${query} - Raw`,
          caloriesPer100g: 52,
          protein: 0.3,
          carbs: 13.8,
          fat: 0.2,
        },
        {
          fdsId: 'demo-2',
          description: `${query} - Cooked`,
          caloriesPer100g: 85,
          protein: 0.5,
          carbs: 22.5,
          fat: 0.3,
        },
      ];
      this.cache.set(cacheKey, { data: mockResults, timestamp: Date.now() });
      return mockResults;
    }

    try {
      const response = await firstValueFrom(
        this.httpService.get(this.usda_api_url, {
          params: {
            query: query,
            pageSize: limit,
            api_key: apiKey,
            dataType: dataType,
          },
        }),
      );
      const foods = response.data.foods || [];
      const results = foods
        .map((food) => this.extractNutrition(food))
        .filter((food): food is FoodNutrition => food !== null);
      this.cache.set(cacheKey, { data: results, timestamp: Date.now() });
      return results;
    } catch (error: any) {
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
        if (!nutrient?.value) return 0;
        return this.normalizePerGram(nutrient.value, servingSize);
      };
      const calories = getNutrient(1008); 
      if (calories <= 0) {
        return null;
      }
      const protein = getNutrient(1003); 
      const carbs = getNutrient(1005); 
      const fat = getNutrient(1004); 
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
  private normalizePerGram(value: number, servingSize: number): number {
    if (servingSize <= 0 || value < 0) return 0;
    return (value / servingSize) * 100;
  }
}