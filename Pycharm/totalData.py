import pandas as pd


class TotalData:
    # 전체 정보를 저장할 변수
    total_data = pd.DataFrame({
        "id": [],
        "cluster_story1": [],
        "cluster_story2": [],
        "cluster_style": [],
        "thumbnail": [],
        "title": [],
        "author": [],
        "day": [],
        "genre": [],
        "story": [],
        "platform": [],
    })

    # 각 클러스터별 핵심 단어를 저장할 변수
    cluster_details = pd.DataFrame({
        "genre": [],
        "cluster_num": [],
        "words": [],
    })

    # 카테고리 목록
    categories = []

    @staticmethod
    def make_total_data(wd):
        my_total_data = pd.DataFrame({
            "id": [],
            "thumbnail": [],
            "title": [],
            "author": [],
            "day": [],
            "genre": [],
            "story": [],
            "platform": [],
        })

        my_total_data['id'] = wd.id_list
        my_total_data['thumbnail'] = wd.thumbnail_list
        my_total_data['title'] = wd.title_list
        my_total_data['author'] = wd.author_list
        my_total_data['day'] = wd.day_list
        my_total_data['genre'] = wd.genre_list
        my_total_data['story'] = wd.story_list
        my_total_data['platform'] = wd.platform_list
        # my_total_data.set_index('id', inplace=True)

        return my_total_data

    @staticmethod
    def merge_total_data(tds):
        TotalData.total_data = pd.concat(tds)
        first_td_len = len(tds[0])
        TotalData.total_data['id'] = TotalData.total_data['id'][:first_td_len].tolist() + [x + first_td_len for x in TotalData.total_data['id'][first_td_len:].tolist()]
        TotalData.total_data.set_index('id', inplace=True)
        TotalData.total_data = TotalData.total_data.loc[:, ~TotalData.total_data.columns.str.contains('^Unnamed')]

    @staticmethod
    def save_category():
        TotalData.categories = list(set(TotalData.total_data['genre']))
        print("\n<웹툰 카테고리 종류 및 개수>")
        print("전체: " + str(len(TotalData.total_data)))
        for genre in TotalData.categories:
            print(genre + ": " + str(len(TotalData.total_data.index[TotalData.total_data['genre'] == genre])))
        print()

