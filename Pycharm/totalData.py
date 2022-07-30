import math

import pandas as pd


class TotalData:
    # 전체 정보를 저장할 변수
    total_data = pd.DataFrame({
        "id": [],
        "title": [],
        "author": [],
        "day": [],
        "first_genre": [],
        "second_genre": [],
        "story": [],
        "platform": [],
    })

    # 카테고리 목록
    categories = []

    # 카테고리 별로 나눈 데이터
    categorized_data = {}

    @staticmethod
    def make_total_data(wd):
        my_total_data = pd.DataFrame({
            "id": [],
            "title": [],
            "author": [],
            "day": [],
            "first_genre": [],
            "second_genre": [],
            "story": [],
            "platform": [],
        })

        my_total_data['id'] = wd.id_list
        my_total_data['title'] = wd.title_list
        my_total_data['author'] = wd.author_list
        my_total_data['day'] = wd.day_list
        my_total_data['first_genre'] = wd.first_genre_list
        my_total_data['second_genre'] = wd.second_genre_list
        my_total_data['story'] = wd.story_list
        my_total_data['platform'] = wd.platform_list

        return my_total_data

    @staticmethod
    def merge_total_data(tds):
        for td in tds:
            TotalData.total_data = pd.concat([TotalData.total_data, td])

    @staticmethod
    def save_category():
        TotalData.categories = list(set(TotalData.total_data['first_genre'].to_list() + TotalData.total_data['second_genre'].to_list()))
        TotalData.categories = [i for i in TotalData.categories if str(i) != 'nan']
        print("웹툰 카테고리: ", TotalData.categories)

    @staticmethod
    def classify_by_category():
        categorized = TotalData.categorized_data
        for category in TotalData.categories:
            TotalData.categorized_data[category] = pd.DataFrame({
                                            "id": [],
                                            "title": [],
                                            "author": [],
                                            "day": [],
                                            "story": [],
                                            "platform": [],
                                        })
            idx = 0
            for _, row in TotalData.total_data.iterrows():
                if category in (row['first_genre'], row['second_genre']):
                    new_data = pd.DataFrame({
                        'id': [row['id']],
                        'title': [row['title']],
                        'author': [row['author']],
                        'day': [row['day']],
                        'story': [row['story']],
                        'platform': [row['platform']]
                    }, index=[idx])
                    idx += 1
                    categorized[category] = categorized[category].append(new_data)
            print(category + " 개수: " + str(len(categorized[category])))
