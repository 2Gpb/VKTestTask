# VKTestTask

## Описание

Приложение отображает список отзывов с рейтингом, текстом и фотографиями. Добавлены интерактивные элементы, кастомные анимации, асинхронная загрузка и кеширование изображений. 

## Условия выполнения

- Верстка с использованием UIKit 
- Соблюден стиль проекта
- Проект без сторонних библиотек

---

## Что реализовано

- **Профиль пользователя:**
  - Аватар
  - Имя и фамилия
  - Рейтинг в виде звёзд
  - Картинки в отзыве

- **Отзывы:**
  - Поддержка нескольких изображений
  - Раскрытие полного текста через кнопку “Показать больше”
  - Отдельная ячейка в конце с количеством отзывов

- **Асинхронная загрузка изображений:**
  - Используется `URLSession`
  - Запросы отменяются при переиспользовании ячеек
  - Для загрузки используется фоновый поток

- **Кеширование изображений:**
  - Используется класс для кеширования изображений через `NSCache`

- **Анимации и стейты загрузки:**
  - Пока загружается изображение, отображается shimmer-анимация (`CAGradientLayer + CABasicAnimation`)
  - Реализован собственный кастомный индикатор загрузки (`CAShapeLayer + rotation`)

- **Оптимизация производительности:**
  - Найдена и устранена утечка памяти: передача замыкания в `ReviewCellConfig`, которое захватывало `ViewModel`
  - Ошибка с подвисанием при скролле была вызвана задержкой загрузки отзывов в `main queue`, переведено в фоновый поток (`GCD`)

- **Интерактивность:**
  - Поддержка `Pull to Refresh` с `UIRefreshControl`

---
