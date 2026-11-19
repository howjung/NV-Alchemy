export class CreateUserDto {
  email: string;
  nickname: string;
  targetWeight?: number;
  dailyCalorieGoal?: number;
}