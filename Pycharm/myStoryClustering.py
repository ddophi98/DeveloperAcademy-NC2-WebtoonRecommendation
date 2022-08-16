import numpy as np
from sklearn.metrics.pairwise import cosine_similarity
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_samples
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import font_manager, rc
import seaborn as sns


class MyStoryClustering:
    top_n_features = 3

    def __init__(self, vectorized, vectorizer, total_data):
        self.vectorized = vectorized
        self.vectorizer = vectorizer
        self.data = total_data
        self.kmeans = KMeans()

        # 한글 폰트 설정
        font_path = "C:/Windows/Fonts/batang.ttc"
        font = font_manager.FontProperties(fname=font_path).get_name()
        rc('font', family=font, size=15)

    # silhoutte 방법으로 적정 k값 구하기
    def get_proper_k(self, data_index):
        max_k = len(data_index) // 10

        # 데이터 개수가 너무 적으면 k=1로 하기
        if max_k <= 1:
            proper_k = 1
        else:
            silhoutte_values = []
            for i in range(2, max_k+1):
                kmeans = KMeans(n_clusters=i, init='k-means++')
                pred = kmeans.fit_predict(self.vectorized[data_index])
                silhoutte_values.append(np.mean(silhouette_samples(self.vectorized[data_index], pred)))

            proper_k = np.argmax(silhoutte_values) + 2

        return proper_k

    # K-means로 군집화시키기
    def kmeans_cluster(self, genre, data_index, k=-1):
        if k == -1:
            cluster_num = self.get_proper_k(data_index)
        else:
            cluster_num = k
        print(genre + ": " + str(cluster_num))
        self.kmeans = KMeans(n_clusters=cluster_num)
        cluster_label = self.kmeans.fit_predict(self.vectorized[data_index])
        return cluster_label

    # 군집별 핵심단어 추출하기
    def get_cluster_details(self, genre):
        # 각 클러스터별 핵심 단어를 저장할 변수
        cluster_details = pd.DataFrame({
            "genre": [],
            "cluster_num": [],
            "words": [],
        })

        feature_names = self.vectorizer.get_feature_names_out()

        # 각 클러스터 레이블별 feature들의 center값들 내림차순으로 정렬 후의 인덱스를 반환
        center_feature_idx = self.kmeans.cluster_centers_.argsort()[:, ::-1]

        # 각 feature별 center값들 정렬한 인덱스 중 상위 값들 추출
        top_features = []
        for cluster_num in range(len(center_feature_idx)):
            top_feature_idx = center_feature_idx[cluster_num, :self.top_n_features]
            top_feature = [feature_names[idx] for idx in top_feature_idx]
            top_features.append(top_feature)

        cluster_details['genre'] = [genre for _ in range(len(center_feature_idx))]
        cluster_details['cluster_num'] = range(len(center_feature_idx))
        cluster_details['words'] = top_features

        return cluster_details

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
