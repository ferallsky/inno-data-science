import numpy as np
import pandas as pd
import os
from sklearn.preprocessing import LabelEncoder  # кодирование категориальных
from sklearn.feature_selection import SelectKBest  # выбор признаков
from sklearn.feature_selection import chi2  # выбор по Хи квадрат
from sklearn.model_selection import train_test_split  # деление на тест и обучение
from sklearn.metrics import accuracy_score, precision_score, recall_score, f1_score
from catboost import CatBoostClassifier


class Settings:

    def __init__(self):
        self.df_row_count = 2001
        self.df_subject_count = 6
        self.df_min_grade = 0
        self.df_max_grade = 99
        self.df_file = 'students.csv'
        self.model_file = 'people_university_model.cbm'
        self.model_file_eff = 'people_university_model_eff.cbm'
        self.resource_folder = 'ml'
        self.final_result_list = ['удовлетворительно', 'хорошо', 'отлично']

        if not os.path.exists(self.resource_folder):
            os.mkdir(self.resource_folder)

    def df_path(self):
        return self.resource_folder + '/' + self.df_file

    def model_path(self):
        return self.resource_folder + '/' + self.model_file

    def model_eff_path(self):
        return self.resource_folder + '/' + self.model_file_eff


class DataframeGenerator:

    def __init__(self, settings: Settings):
        self.__settings = settings

    def generate(self):
        subjects = [f"subject_{num + 1}" for num in range(self.__settings.df_subject_count)]

        grades = np.random.randint(
            self.__settings.df_min_grade,
            self.__settings.df_max_grade + 1,
            (self.__settings.df_row_count, self.__settings.df_subject_count)
        )
        student_scores = pd.DataFrame(grades, columns=subjects)

        student_scores.sum(axis=0)
        student_scores['mean_score'] = np.round((student_scores.sum(axis=1) / self.__settings.df_subject_count), 3)

        student_scores['final_lab'] = student_scores.apply(self.__generate_final, axis=1)

        return student_scores

    def __generate_final(self, row):
        score = row['mean_score']
        if score < 35:
            val = self.__settings.final_result_list[0]
        elif 35 <= score < 60:
            val = self.__settings.final_result_list[1]
        else:
            val = self.__settings.final_result_list[2]
        return val


class StudentRepository:

    def __init__(self, settings: Settings):
        self.__data_generator = DataframeGenerator(settings)
        self.__settings = settings

    def create(self):
        return self.__data_generator.generate()

    def store(self):
        df = self.create()
        df.to_csv(self.__settings.df_path(), index=False)

    def load(self):
        return pd.read_csv(self.__settings.df_path())

    def loadOrCreate(self, override=False):
        if override or not os.path.exists(self.__settings.df_path()):
            self.store()
        return self.load()


class ModelService:

    @staticmethod
    def train_model(x_train, y_train, iterations=100, depth=4, learning_rate=0.1, file_to_save=''):
        model = CatBoostClassifier(iterations=iterations, depth=depth, learning_rate=learning_rate)
        model.fit(x_train, y_train)
        model.save_model(file_to_save)

    @staticmethod
    def preprocess_dataset(
            df,
            to_drop=['final_lab', 'mean_score'],
            y_name='final_lab',
            need_to_encode_y=True,
            need_best_features=True,
            test_size=0.2,
            random_state=1234
    ):
        X = df.drop(columns=to_drop, axis=1)
        y = df[y_name]  # Series

        if need_to_encode_y:
            label_encoder = LabelEncoder()
            temp = label_encoder.fit_transform(y)
            new_result = pd.DataFrame([y, temp], columns=['y', 'encoded_y'])
            new_result.to_csv('ml/result_labels.csv', index=False)
            y = temp

        if need_best_features:
            # 2. Выберите лучшие 3 признака для обучения
            selector = SelectKBest(chi2, k=3)
            X = selector.fit_transform(X, y)

        # 3. Разбейте датасет на тестовую и обучающую выборку train_test_split (для лучших признаков)
        # 80% обучающей выборки, 20% тестовой
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=test_size, random_state=random_state)

        return X_train, X_test, y_train, y_test

    @staticmethod
    def model_report(model, x_test, y_test, average='weighted'):
        y_pred = model.predict(x_test)
        return {
            'accuracy': accuracy_score(y_test, y_pred),
            'precision': precision_score(y_test, y_pred, average=average),
            'recall': recall_score(y_test, y_pred, average=average),
            'f1': f1_score(y_test, y_pred, average=average)
        }

    @staticmethod
    def load_model(path_to_model=''):
        new_model = CatBoostClassifier()
        new_model.load_model(path_to_model)
        return new_model
