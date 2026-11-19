import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  ParseIntPipe,
  Delete,
  UseInterceptors,
  UploadedFile,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { diskStorage } from 'multer';
import { extname } from 'path';
import { UserId } from '../auth/user-id.decorator';
import { MealsService } from './meals.service';
import { CreateMealDto } from './dto/create-meal.dto';
import { UpdateMealDto } from './dto/update-meal.dto';

@Controller('meals')
export class MealsController {
  constructor(private readonly mealsService: MealsService) {}

  @Post('upload')
  @UseInterceptors(
    FileInterceptor('file', {
      storage: diskStorage({
        destination: './uploads',
        filename: (req, file, cb) => {
          const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
          cb(null, `${uniqueSuffix}${extname(file.originalname)}`);
        },
      }),
    }),
  )
  async uploadImage(@UploadedFile() file: Express.Multer.File) {
    const analysis = await this.mealsService.analyzeFoodImage(
      file.path,
      file.mimetype,
    );

    return {
      imageUrl: `/uploads/${file.filename}`,
      ...analysis,
    };
  }

  @Post()
  create(@UserId() userId: number, @Body() dto: CreateMealDto) {
    return this.mealsService.create(userId, dto);
  }

  @Get()
  findAll(@UserId() userId: number) {
    return this.mealsService.findAll(userId);
  }

  @Get(':id')
  findOne(@UserId() userId: number, @Param('id', ParseIntPipe) id: number) {
    return this.mealsService.findOne(userId, id);
  }

  @Patch(':id')
  update(@UserId() userId: number, @Param('id', ParseIntPipe) id: number, @Body() dto: UpdateMealDto) {
    return this.mealsService.update(userId, id, dto);
  }

  @Delete(':id')
  remove(@UserId() userId: number, @Param('id', ParseIntPipe) id: number) {
    return this.mealsService.remove(userId, id);
  }
}
