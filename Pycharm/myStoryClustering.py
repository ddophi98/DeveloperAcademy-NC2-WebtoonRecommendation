import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_samples
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import font_manager, rc
import seaborn as sns


class MyStoryClustering:
    top_n_features = 5

    def __init__(self, vectorized, vectorizer, categorized_data):
        self.vectorized = vectorized
        self.vectorizer = vectorizer
        self.data = categorized_data
        self.cluster_num = self.get_proper_k()
        self.kmeans = KMeans(n_clusters=self.cluster_num, init='k-means++')

        # 한글 폰트 설정
        font_path = "C:/Windows/Fonts/batang.ttc"
        font = font_manager.FontProperties(fname=font_path).get_name()
        rc('font', family=font, size=15)

    # silhoutte 방법으로 적정 k값 구하기
    def get_proper_k(self):
        max_k = len(self.data) // 10

        # 데이터 개수가 너무 적으면 k=1로 하기
        if max_k <= 1:
            return 1

        silhoutte_values = []
        for i in range(2, max_k+1):
            kmeans = KMeans(n_clusters=i, init='k-means++')
            pred = kmeans.fit_predict(self.vectorized)
            silhoutte_values.append(np.mean(silhouette_samples(self.vectorized, pred)))

        proper_k = np.argmax(silhoutte_values)

        print("적정 k값: " + str(proper_k))
        return proper_k

    # K-means로 군집화시키기
    def kmeans_cluster(self):
        cluster_label = self.kmeans.fit_predict(self.vectorized)
        self.data['cluster_label'] = cluster_label
        self.data = self.data.sort_values(by=['cluster_label'])

    # 군집별 핵심단어 추출하기
    def get_cluster_details(self):
        feature_names = self.vectorizer.get_feature_names_out()
        cluster_details = {}
        # 각 클러스터 레이블별 feature들의 center값들 내림차순으로 정렬 후의 인덱스를 반환
        center_feature_idx = self.kmeans.cluster_centers_.argsort()[:, ::-1]

        # 개별 클러스터 레이블별로
        for cluster_num in range(self.cluster_num):
            # 개별 클러스터별 정보를 담을 empty dict할당
            cluster_details[cluster_num] = {}
            cluster_details[cluster_num]['cluster'] = cluster_num

            # 각 feature별 center값들 정렬한 인덱스 중 상위 값들 추출
            top_ftr_idx = center_feature_idx[cluster_num, :self.top_n_features]
            top_ftr = [feature_names[idx] for idx in top_ftr_idx]
            # top_ftr_idx를 활용해서 상위 10개 feature들의 center값들 반환
            # 반환하게 되면 array이기 떄문에 리스트로바꾸기
            top_ftr_val = self.kmeans.cluster_centers_[cluster_num, top_ftr_idx].tolist()
            # cluster_details 딕셔너리에다가 개별 군집 정보 넣어주기
            cluster_details[cluster_num]['top_features'] = top_ftr
            cluster_details[cluster_num]['top_featrues_value'] = top_ftr_val
            # 해당 cluster_num으로 분류된 파일명(문서들) 넣어주기
            title = self.data[self.data['cluster_label'] == cluster_num]['title']
            story = self.data[self.data['cluster_label'] == cluster_num]['story']
            # filenames가 df으로 반환되기 떄문에 값들만 출력해서 array->list로 변환
            title = title.values.tolist()
            story = story.values.tolist()
            cluster_details[cluster_num]['title'] = title
            cluster_details[cluster_num]['story'] = story

        return cluster_details

    # 군집별 핵심단어 출력해보기
    def print_cluster_details(self):
        cluster_details = self.get_cluster_details()
        for cluster_num, cluster_detail in cluster_details.items():
            print()
            for i in range(len(cluster_detail['title'])):
                print()
                print(f"Cluster Num: {cluster_num}")
                print(cluster_detail['top_features'])
                print("제목 - " + cluster_detail['title'][i])
                print(cluster_detail['story'][i])
                print('-' * 40)
            print('\n\n' + '~' * 160 + '\n\n')

    # 유사도 그래프로 비교해보기
    def compare_similarity(self, item_title):
        self.data = self.data.sort_index()

        # 해당 제목을 가진 웹툰이 어느 클러스터에 속해있고 인덱스는 몇인지 구하기
        target_cluster = 0
        selected_item_idx = 0
        for idx, row in self.data.iterrows():
            if row['title'] == item_title:
                target_cluster = row['cluster_label']
                selected_item_idx = idx
                break

        selected_cluster_idx = self.data[self.data['cluster_label'] == target_cluster].index
        # 해당 카테고리로 클러스터링 된 문서들의 인덱스 중 하나 선택해 비교 기준으로 삼을 문서 선정
        print("유사도 비교 기준 문서 이름:", item_title)
        print()

        print(self.data[self.data['cluster_label'] == target_cluster])
        print()

        # 위에서 추출한 카테고리로 클러스터링된 문서들의 인덱스 중 비교기준문서를 제외한 다른 문서들과의 유사도 측정
        similarity = cosine_similarity(self.vectorized[selected_item_idx], self.vectorized[selected_cluster_idx])

        # array 내림차순으로 정렬한 후 인덱스 반환
        sorted_idx = np.argsort(similarity)[:, ::-1]
        # 비교문서 당사자는 제외한 인덱스 추출 (내림차순 정렬했기때문에 0번째가 무조건 가장 큰 값임)
        sorted_idx = sorted_idx[:, 1:]

        # index로 넣으려면 1차원으로 reshape해주기
        sorted_idx = sorted_idx.reshape(-1)

        # 앞에서 구한 인덱스로 유사도 행렬값도 정렬
        sorted_sim_values = similarity.reshape(-1)[sorted_idx]

        # 그래프 생성
        selected_sim_df = pd.DataFrame()
        selected_sim_df['title'] = self.data[self.data['cluster_label'] == target_cluster].iloc[sorted_idx]['title']
        selected_sim_df['similarity'] = sorted_sim_values

        plt.figure(figsize=(25, 10), dpi=60)
        sns.barplot(data=selected_sim_df, x='similarity', y='title')
        plt.title(item_title)
        plt.show()
