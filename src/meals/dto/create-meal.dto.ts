export class CreateMealDto {
  mealType: string;
  foodName: string;
  calories: number;
  carbs?: number;
  protein?: number;
  fat?: number;
  imageUrl?: string;
  recordedDate: string;
  userId: number;
}