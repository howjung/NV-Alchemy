import { Body, Controller, Delete, Get, Param, ParseIntPipe, Patch, Post } from '@nestjs/common';
import { UserId } from '../auth/user-id.decorator';
import { CreateWeightDto } from './dto/create-weight.dto';
import { UpdateWeightDto } from './dto/update-weight.dto';
import { WeightsService } from './weights.service';

@Controller('weights')
export class WeightsController {
  constructor(private readonly weights: WeightsService) {}

  @Post()
  create(@UserId() userId: number, @Body() dto: CreateWeightDto) {
    return this.weights.create(userId, dto);
  }

  @Get()
  findAll(@UserId() userId: number) {
    return this.weights.findAll(userId);
  }

  @Get(':id')
  findOne(@UserId() userId: number, @Param('id', ParseIntPipe) id: number) {
    return this.weights.findOne(userId, id);
  }

  @Patch(':id')
  update(@UserId() userId: number, @Param('id', ParseIntPipe) id: number, @Body() dto: UpdateWeightDto) {
    return this.weights.update(userId, id, dto);
  }

  @Delete(':id')
  remove(@UserId() userId: number, @Param('id', ParseIntPipe) id: number) {
    return this.weights.remove(userId, id);
  }
}
