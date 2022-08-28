import os.path

import pandas as pd

from totalData import TotalData as td
from myWebCrawling import MyWebCrawling
from myUtil import MyUtil as ut
from myTokenize import MyTokenize
from myStoryClustering import MyStoryClustering
from myStyleClustering import MyStyleClustering


naver_csv_filename = "data/네이버웹툰정보.csv"
kakao_csv_filename = "data/카카오웹툰정보.csv"
cluster_csv_filename = "data/클러스터정보.csv"
cluster_detail_csv_filename = "data/클러스터상위단어.csv"
vector_filename = "data/vector_data.pickle"
images_filename = "data/images.pickle"

# 네이버 및 카카오 웹툰 크롤링 하기 (새로 하기 또는 저장된 데이터 불러오기)
def do_web_crawling():
    wc = MyWebCrawling()

    # 네이버 웹툰 정보 가져오기
    print("--naver webtoon crawling start--")
    if not os.path.isfile(naver_csv_filename):
        naver_wd = wc.get_naver_webtoon_info()
        naver_td = td.make_total_data(naver_wd)
        ut.make_csv(naver_csv_filename, naver_td)
    else:
        naver_td = ut.get_from_csv(naver_csv_filename)
    print("--naver webtoon crawling end--")

    # 카카오 웹툰 정보 가져오기
    print("--kakao webtoon crawling start--")
    if not os.path.isfile(kakao_csv_filename):
        # 데이터 양이 많아서 요일별로 끊어서 파일 만들고 합치기
        kakao_td = wc.get_kakao_webtoon_info()
        ut.make_csv(kakao_csv_filename, kakao_td)
    else:
        kakao_td = ut.get_from_csv(kakao_csv_filename)
    print("--kakao webtoon crawling end--")

    # 가져온 데이터들 합치기
    td.merge_total_data([naver_td, kakao_td])
    # 웹툰 카테고리 분류하기
    td.save_category()

# 토큰화 및 벡터화하기 (새로 하기 또는 저장된 데이터 불러오기)
def do_tokenize_and_vectorize():
    print("--vectorized start--")
    if not os.path.isfile(vector_filename):
        tk = MyTokenize(td.total_data)
        vectorized = tk.get_vectorized_data()
        vectorizer = tk.tfidf_vectorizer
        ut.save_data(vector_filename, (vectorized, vectorizer))
    else:
        vectorized, vectorizer = ut.load_data(vector_filename)
    print("--vectorized end--")
    story_ct = MyStoryClustering(vectorized, vectorizer, td.total_data)
    return story_ct

# story에 대한 k-means 클러스터링 하기
def do_clustering_by_story(story_ct, k_for_total=175):
    print("--kmeans story clustering start--")
    print("\n<적정 k값>")

    cluster_details_list = []

    # 전체 웹툰 안에서 클러스터링 하기
    total_index = list(range(len(td.total_data)))
    cluster_labels_for_whole = story_ct.kmeans_cluster("전체", total_index, k=k_for_total)
    cluster_details = story_ct.get_cluster_details("전체")
    cluster_details_list.append(cluster_details)
    # story_ct.visualize(cluster_labels_for_whole)

    # 각 장르 안에서 클러스터링 하기
    cluster_labels_for_genre = [-1 for _ in range(len(td.total_data))]
    for genre in td.categories:
        current_data_index = td.total_data.index[td.total_data['genre'] == genre].tolist()
        current_data_index = list(map(int, current_data_index))
        cluster_label = story_ct.kmeans_cluster(genre, current_data_index)
        for i in range(len(current_data_index)):
            cluster_labels_for_genre[current_data_index[i]] = cluster_label[i]
        cluster_details = story_ct.get_cluster_details(genre)
        cluster_details_list.append(cluster_details)

    print()
    td.total_data["cluster_story"] = cluster_labels_for_whole
    td.total_data["cluster_story_in_genre"] = cluster_labels_for_genre
    td.cluster_details = pd.concat(cluster_details_list)
    print("--kmeans story clustering end--")

# style에 대한 k-means 클러스터링 하기
def do_clustering_by_style(style_ct, k):
    # 이미지 로딩하기 (새로 하기 또는 저장된 데이터 불러오기)
    print("--images loading start--")
    if not os.path.isfile(images_filename):
        thumbnails = style_ct.get_img()
        ut.save_data(images_filename, thumbnails)
    else:
        thumbnails = ut.load_data(images_filename)
    print("--images loading end--")
    print("--style extraction start--")
    # 각 이미지마다 스타일 추출하기
    style_ct.extract_style(thumbnails)
    print("--style extraction end--")
    print("--kmeans style clustering start--")
    # 추출한 스타일로 k-means 클러스터링 하기
    cluster_labels = style_ct.kmeans_cluster(k)
    td.total_data["cluster_style"] = cluster_labels
    style_ct.visualize(cluster_labels)
    print("--kmeans style clustering end--")

# 각 클러스터에 대해 유사도가 높은 데이터만 따로 정리해놓기
def arrange_high_similarity_webtoons(story_ct, style_ct):
    print("-- similarity calculation start--")
    cluster_story_group = []
    cluster_story_group_in_genre = []
    cluster_style_group = []
    for idx, row in td.total_data.iterrows():
        cluster_story_group.append(story_ct.compare_similarity(idx, row, "cluster_story"))
        cluster_story_group_in_genre.append(story_ct.compare_similarity(idx, row, "cluster_story_in_genre"))
        cluster_style_group.append(style_ct.compare_similarity(idx, row))
    td.total_data["cluster_story_group"] = cluster_story_group
    td.total_data["cluster_story_group_in_genre"] = cluster_story_group_in_genre
    td.total_data["cluster_style_group"] = cluster_style_group
    print("-- similarity calculation end--")

if __name__ == '__main__':
    do_web_crawling()
    story_clustering = do_tokenize_and_vectorize()
    style_clustering = MyStyleClustering(td.total_data)
    do_clustering_by_story(story_clustering, k_for_total=50)
    do_clustering_by_style(style_clustering, k=50)
    arrange_high_similarity_webtoons(story_clustering, style_clustering)
    ut.save_images(td.total_data['thumbnail'])
    ut.make_csv(cluster_csv_filename, td.total_data)
    ut.make_csv(cluster_csv_filename, td.total_data)
    ut.make_csv(cluster_detail_csv_filename, td.cluster_details)

