import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post } from '@nestjs/common';
import { UserId } from '../auth/user-id.decorator';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';
import { MealsService } from './meals.service';

@Controller('meals')
export class MealsController {
  constructor(private readonly meals: MealsService) {}

  @Post()
  create(@UserId() userId: number, @Body() dto: CreateMealDto) {
    return this.meals.create(userId, dto);
  }

  @Get()
  findAll(@UserId() userId: number) {
    return this.meals.findAll(userId);
  }

  @Get(':id')
  findOne(@UserId() userId: number, @Param('id', ParseIntPipe) id: number) {
    return this.meals.findOne(userId, id);
  }

  @Patch(':id')
  update(@UserId() userId: number, @Param('id', ParseIntPipe) id: number, @Body() dto: UpdateMealDto) {
    return this.meals.update(userId, id, dto);
  }

  @Delete(':id')
  remove(@UserId() userId: number, @Param('id', ParseIntPipe) id: number) {
    return this.meals.remove(userId, id);
  }
}
