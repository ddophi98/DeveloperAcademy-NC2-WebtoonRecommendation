import os.path

from totalData import TotalData as td
from myWebCrawling import MyWebCrawling
from myUtil import MyUtil as ut
from myTokenize import MyTokenize
from myStoryClustering import MyStoryClustering
from myStyleClustering import MyStyleClustering


naver_csv_filename = "네이버웹툰정보.csv"
kakao_csv_filename = "카카오웹툰정보.csv"
vector_filename_form = "vector_data.pickle"
genre = "소년"
vector_filename = genre + "_" + vector_filename_form
webtoonName = "나 혼자만 레벨업"

if __name__ == '__main__':
    wc = MyWebCrawling()

    # 네이버 웹툰 정보 가져오기 (크롤링 또는 저장된 데이터 불러오기)
    if not os.path.isfile(naver_csv_filename):
        print("--naver web crawling start--")
        naver_wd = wc.get_naver_webtoon_info()
        print("--naver web crawling end--")
        naver_td = td.make_total_data(naver_wd)
        ut.make_csv(naver_csv_filename, naver_td)
        print("--saving naver csv file end--")
    else:
        naver_td = ut.get_from_csv(naver_csv_filename)
        print("--getting naver csv file end--")

    # 카카오 웹툰 정보 가져오기 (크롤링 또는 저장된 데이터 불러오기)
    if not os.path.isfile(kakao_csv_filename):
        # # 이상적인 과정
        # print("--kakao web crawling start--")
        # kakao_wd = wc.get_kakao_webtton_info()
        # print("--kakao web crawling end--")
        # kakao_td = td.make_total_data(kakao_wd)
        # print("--making total dataframe end--")

        # 웹 데이터가 로드가 안되는 오류 때문에 요일별로 끊어서 파일 만드는 과정
        print("--kakao web crawling start--")
        kakao_td = wc.get_and_form_kakao_webtton_info_by_day()
        print("--making total dataframe end--")

        ut.make_csv(kakao_csv_filename, kakao_td)
        print("--saving kakao csv file end--")
    else:
        kakao_td = ut.get_from_csv(kakao_csv_filename)
        print("--getting kakao csv file end--")

    # 가져온 데이터들 합치기
    td.merge_total_data((naver_td, kakao_td))

    # 웹툰 카테고리 분류하기
    td.save_category()
    td.classify_by_category()
    print("--categorizing end--")

    if genre == "전체":
        current_data = td.total_data
    else:
        current_data = td.categorized_data[genre]

    # 토큰화 및 벡터화하기 (새로 하기 또는 이미 되어있는 값 불러오기)
    if not os.path.isfile(vector_filename):
        print("--vectorized start--")
        tk = MyTokenize(current_data)
        vectorized = tk.get_vectorized_data()
        vectorizer = tk.tfidf_vectorizer
        ut.save_data(vector_filename, (vectorized, vectorizer))
        print("--vectorized save end--")
    else:
        vectorized, vectorizer = ut.load_data(vector_filename)
        print("--vectorized load end--")

    # story에 대한 k-means 클러스터링 하기
    print("--kmeans story clustering start--")
    story_ct = MyStoryClustering(vectorized, vectorizer, current_data)
    story_ct.kmeans_cluster()
    print("--kmeans clustering end--")
    story_ct.print_cluster_details()
    story_ct.compare_similarity(webtoonName)

    # style에 대한 k-means 클러스터링 하기
    print("--kmeans style clustering start--")
    style_ct = MyStyleClustering(td.total_data)
    thumbnails = style_ct.get_img()
    style_info_list = style_ct.extract_style(thumbnails)
    results = style_ct.kmeans_cluster(style_info_list)
    style_ct.print_cluster_details(results)


