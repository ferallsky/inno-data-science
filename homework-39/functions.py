from sklearn.preprocessing import LabelEncoder  # кодирование категориальных
from sklearn.feature_selection import SelectKBest  # выбор признаков
from sklearn.feature_selection import chi2  # выбор по Хи квадрат
from sklearn.model_selection import train_test_split  # деление на тест и обучение
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from catboost import CatBoostClassifier
import pandas as pd


def classifyStudent(new_student, new_columns, model_file, categories=[0, 1, 2]):
    '''
    Функция для классификации студентов
    @param new_student - массив ключ-значение
    '''
    # Чтение обученной модели из файла
    model = CatBoostClassifier()
    model.load_model(model_file)

    # Преобразование данных студента в DataFrame
    new_data = pd.DataFrame([new_student], columns=new_columns)

    # Использование модели для предсказания
    predicted_category = model.predict(new_data)[0]

    # Преобразование обратно в текстовую категорию
    categories = [...]  # категориальная по студентам
    predicted_category = categories[predicted_category]

    return predicted_category