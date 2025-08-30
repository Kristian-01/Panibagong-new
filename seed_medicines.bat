@echo off
echo Seeding medicines and vitamins to database...
echo.

cd nine27-pharmacy-backend

echo Running database seeder...
php artisan db:seed --class=MedicineListSeeder

echo.
echo Medicine seeding completed!
echo.
pause
