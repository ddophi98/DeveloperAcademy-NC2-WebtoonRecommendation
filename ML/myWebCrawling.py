import pandas as pd
import requests
import datetime
from bs4 import BeautifulSoup as bs
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver import ActionChains
from time import sleep
from webtoonData import WebtoonData
from totalData import TotalData as td
from myUtil import MyUtil as ut
import os.path


class MyWebCrawling:
    nw_url = 'https://comic.naver.com/webtoon/weekday'
    kw_url = 'https://page.kakao.com/main?categoryUid=10&subCategoryUid=1002'
    chromedriver_url = 'C:/Storage/Storage_Coding/PycharmProjects/SideProjcet-WebtoonRecommendation/Pycharm/chromedriver'
    login_id = 'barezebe119@naver.com'
    login_pw = 'Whiteout00'

    # 네이버 웹툰 각각의 정보 가져오기
    def get_naver_webtoon_info(self):
        wd = WebtoonData()
        html = requests.get(self.nw_url).text
        soup = bs(html, 'html.parser')
        title = soup.find_all('a', {'class': 'title'})
        driver = webdriver.Chrome(self.chromedriver_url)
        driver.get(self.nw_url)

        # 각각의 웹툰 정보 수집 시작
        idx = 0
        for i in range(len(title)):
            sleep(0.5)
            print("\rprocess: " + str(i + 1) + " / " + str(len(title)), end="")
            # 월요일 첫 번째 웹툰부터 순서대로 클릭
            page = driver.find_elements(By.CLASS_NAME, "title")
            page[i].click()

            # 이동한 페이지 주소 읽고 파싱
            html = driver.page_source
            soup = bs(html, 'html.parser')

            # 요일 수집
            day = soup.find_all('ul', {'class': 'category_tab'})
            day = day[0].find('li', {'class': 'on'}).text[0:1]

            # 요일 두 개 이상이면 요일만 추가함
            current_title = title[i].text
            if current_title in wd.title_list:
                wd.day_list[wd.title_list.index(current_title)] += ', ' + day
                driver.back()
                continue

            # 나머지 정보 수집
            image_url = soup.find('div', {'class': 'thumb'}).find('a').find('img')
            image_url = image_url['src']
            author = soup.find('span', {'class': 'wrt_nm'}).text[8:]
            author = author.replace(' / ', ', ')
            genre = soup.find('span', {'class': 'genre'}).text.split(", ")
            story = soup.find('div', {'class': 'detail'}).find('p').text

            # 리스트에 추가
            wd.id_list.append(idx)
            wd.thumbnail_list.append(image_url)
            wd.title_list.append(current_title)
            wd.author_list.append(author)
            wd.day_list.append(day)
            if genre[1] == "무협/사극":
                wd.genre_list.append("무협")
            else:
                wd.genre_list.append(genre[1])
            wd.story_list.append(story)
            wd.platform_list.append("네이버웹툰")

            # 뒤로 가기
            idx += 1
            driver.back()
            sleep(0.5)

        print()
        return wd

    # 카카오 웹툰 각각의 정보 가져오고 파일로까지 저장하기 (요일 단위로)
    def get_and_form_kakao_webtton_info_by_day(self):
        driver = webdriver.Chrome(self.chromedriver_url)
        action = ActionChains(driver)
        driver.get(self.kw_url)
        sleep(3)
        # 로그인 해야 들어갈 수 있는 것들 때문에 일단 로그인하기
        self.login_on_kakao_page(driver)

        # 완결 웹툰은 일단 제외하고 요일별 페이지 가져오기
        days = driver.find_elements(By.CLASS_NAME, "e1201h8a0")[:-1]

        day_tds = []
        filenames = []

        idx = 0
        for i in range(len(days)):
            filename = "kakao" + str(i) + ".csv"
            filenames.append(filename)
            if os.path.isfile(filename):
                day_tds.append(ut.get_from_csv(filename))
                idx += len(day_tds[-1])
                continue

            day_wd = WebtoonData()
            total_titles = []

            # 요일별 페이지에 있는 웹툰들 가져오기 (스크롤해야 보이는 것 까지 포함)
            day = driver.find_elements(By.CLASS_NAME, "e1201h8a0")[i]
            action.move_to_element(day).click().perform()
            self.do_scroll_down(10, driver)
            webtoons = driver.find_elements(By.CLASS_NAME, "css-qm6qod")

            # 웹툰별로 정보 저장하기
            for j in range(len(webtoons)):
                print("\rday[" + str(i) + "] - process: " + str(j + 1) + " / " + str(len(webtoons)), end="")

                # 해당 웹툰으로 이동하기
                webtoon = driver.find_elements(By.CLASS_NAME, "css-qm6qod")[j]
                action.move_to_element(webtoon).key_down(Keys.CONTROL).click().key_up(Keys.CONTROL).perform()
                sleep(2)
                driver.switch_to.window(driver.window_handles[1])

                # 이미지 정보 먼저 저장하기
                html = driver.page_source
                soup = bs(html, 'html.parser')
                image_url = soup.find('div', {'class': 'css-1y42t5x'}).find('img')
                image_url = image_url['src']
                image_url = "https:" + image_url

                # 작품소개 창 열기
                notice = driver.find_elements(By.CLASS_NAME, "jsx-3114325382")
                if notice:
                    notice[0].click()
                driver.find_element(By.CLASS_NAME, "css-nxuz68").click()

                # 현재 창에서 데이터 읽기
                sleep(0.5)
                html = driver.page_source
                soup = bs(html, 'html.parser')

                title = soup.find('h2', {'class': 'css-jgjrt'}).text
                day = soup.find_all('div', {'class': 'css-7a7cma'})[0].text
                day = day[:day.find(" 연재")]
                author = soup.find_all('div', {'class': 'css-7a7cma'})[1].text
                author = author.replace(',', ', ')
                genre = soup.find('div', {'class': 'infoBox'})
                genre = genre.find_all('div', {'class': 'jsx-3755015728'})[2].text
                genre = genre[genre.find("웹툰") + 2:]
                story = soup.find('div', {'class': 'descriptionBox'}).text

                # 다른 요일에서 이미 추가된거면 스킵하기
                if title in total_titles:
                    continue

                # 리스트에 추가
                day_wd.id_list.append(idx)
                day_wd.thumbnail_list.append(image_url)
                day_wd.title_list.append(title)
                day_wd.author_list.append(author)
                day_wd.day_list.append(day)
                if genre == "액션무협":
                    day_wd.genre_list.append("무협")
                else:
                    day_wd.genre_list.append(genre)
                day_wd.story_list.append(story)
                day_wd.platform_list.append("카카오웹툰")
                total_titles.append(title)

                idx += 1
                # 다시 메인페이지로 돌아가기
                driver.close()
                driver.switch_to.window(driver.window_handles[0])
                sleep(0.5)

            day_tds.append(td.make_total_data(day_wd))
            ut.make_csv(filename, day_tds[-1])

        # 요일별로 만든 dataframe 모두 합치고 기존 것들은 지우기
        total_td = pd.concat(day_tds)
        for filename in filenames:
            ut.delete_csv(filename)

        print()
        return total_td

    # 카카오 페이지에 로그인 하기
    def login_on_kakao_page(self, driver):
        # 로그인 페이지로 이동하기
        driver.find_elements(By.CLASS_NAME, 'css-vurnku')[1].click()
        sleep(1)
        driver.switch_to.window(driver.window_handles[1])
        # 아이디 및 패스워드 입력하고 로그인 누르기
        driver.find_element(By.NAME, 'email').send_keys(self.login_id)
        driver.find_element(By.NAME, 'password').send_keys(self.login_pw)
        driver.find_element(By.CLASS_NAME, 'btn_confirm').click()
        sleep(1)
        driver.switch_to.window(driver.window_handles[0])
        sleep(1)

    # 스크롤을 내려야 나오는 데이터를 얻기 위해 스크롤하기
    def do_scroll_down(self, seconds, driver):
        start = datetime.datetime.now()
        end = start + datetime.timedelta(seconds=seconds)
        while True:
            driver.find_element(By.TAG_NAME, 'body').send_keys(Keys.PAGE_DOWN)
            sleep(0.5)
            if datetime.datetime.now() > end:
                break
