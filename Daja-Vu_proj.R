# 1. 전체 데이터 확인 작업
df <- read.table("dada\\funda_train.csv", header = T,  fileEncoding = "UTF-8", sep = ",")

head(df)
tail(df)
dim(df)

df[df$amount > 400000, ]

sum(is.na.data.frame(df))
# type_of_business에 NULL이 있음
# store_id, card_id는 범주형 수니까 패스
summary(df[, 3:9])

attach(df)
unique(type_of_business)
summary(transacted_date)

# transacted_date: 2016-06-01 ~ 2019-02-28
dates = sort(unique(df$transacted_date))
head(dates)
tail(dates)



# 2. 맡은 파트별로 카테고리 붙이기
df %>% filter(type_of_business == "기타 미용업") %>%
  head

ff = c("가정용 세탁업", "간판 및 광고물 제조업", "결혼 상담 및 준비 서비스업", "경영 컨설팅업",
       "그 외 기타 분류 안된 사업지원 서비스업", "기록매체 복제업", "기타 건물 관련설비 설치 공사업",
       "기타 엔지니어링 서비스업", "기타 일반 및 생활 숙박시설 운영업", "스포츠 및 레크리에이션 용품 임대업",
       "애완동물 장묘 및 보호 서비스업", "애완용 동물 및 관련용품 소매업", "여관업", "여행사업", "예식장업",
       "인물사진 및 행사용 영상 촬영업", "자동차 세차업", "자동차 전문 수리업", "자동차 종합 수리업",
       "체형 등 기타 신체관리 서비스업", "통신장비 수리업", "택배업")
# length(ff)

rectified = c()
for (i in ff) {
  simple = df %>% filter(type_of_business == i)
  simple["cate"] = "서비스업"
  rectified = bind_rows(rectified, simple)
}
rectified %>% dim
rectified %>% head

rectified[rectified$type_of_business == "택배업", "cate"] = "유통업"
rectified %>% filter(cate == "서비스업") %>% dim
rectified %>% filter(cate == "유통업") %>% dim

write.csv(rectified, "업종_서비스유통.csv")
# write.csv(rectified, "업종_서비스.csv")
# write.csv(rectified, "업종_유통.csv")



# 3. 변수로 취급할 것들
# 날짜(transacted_date일, 월), 시간(transacted_time), 분류(cate), 판매량(amount)

# 한 번 확인해보려고 했으나
library(dplyr)
# plot(df$type_of_business, df$amount)
# corrplot(df$type_of_business, df$amount)

library(ggplot2)
# df %>% filter(type_of_business, amount) %>%
#   group_by(type_of_business) %>%
#   summarise(summ = sum(amount)) %>%
#   ggplot()


# 3-1. 판매량을 변수로 이용해볼 순 없는 걸까.
rectified %>%
  # filter(between(transacted_date, unique(rectified$transacted_date)[1], unique(rectified$transacted_date)[185])) %>%
  group_by(cate, transacted_date) %>%
  summarise(sumV = sum(amount)) %>%
  # summarise(minV = min(amount), medianV = median(amount), meanV = mean(amount), maxV = max(amount)) %>%
  ggplot(aes(color = cate)) +
  geom_point(aes(x = transacted_date, y = sumV))

# 그냥 그려봤는데 이상해서 확인해보고 싶었다.
length(rectified$card_id)
summary(rectified$card_id)

length(unique(rectified[rectified$amount < 0, "card_id"]))
summary(rectified$amount)

# 뭔가 이상한데, 원 데이터는 어떻게 보일까.
rectified = read.csv(file.choose(), header = T)
head(rectified)

rectified %>%
  ggplot(aes(x = type_of_business, y = amount)) +
  geom_boxplot()

colnames(rectified)
length(rectified$amount)

# 결론: 판매량이 보통 이용하는 돈의 단위가 아니라서 안 될 것 같음.


# 3-2. 그렇다면 카드를 긁은 시간은 어떨까.
# 우리가 만든 카테고리로 '전체'를 먼저 만들자.
total = c()
# 원래 for문, 읽어와서 규격에 맞추고 합치고.
part = read.csv(file.choose(), header = T)
part %>% head
colnames(part)
coln = colnames(part)
if (coln[1] != "store_id" && dim(part)[2] > 9) {
  part = part[, 2:dim(part)[2]]
}
part["cate"] = "휴게 음식점"
total = bind_rows(total, part)

total %>% dim
write.csv(total, "total.csv")
total = read.csv("total.csv")
total %>% dim

# 그냥 얘기하는 거에서 확인해보고 싶었던 것들.
# rectified[rectified$transacted_time >= 3, ]
# rectified[rectified$transacted_time == "00:25", "amount"]


# 3-2-1. 전체에서 시각적으로 확인해보자.
total %>%
  # filter(cate != "일반 음식점") %>%
  group_by(cate, transacted_time) %>%
  summarise(times = length(amount), refund = sum(amount < 0)) %>%
  ggplot(aes(color = cate)) +
  geom_point(aes(x = transacted_time, y = times)) +
  geom_vline(xintercept = c("9:00", "12:00", "15:00", "18:00", "21:00"))
  # guides(color = F)

# 역시 판매량은 쓸 수 없을 것 같다.


# 3-2-2. category별로 할 순 없는 걸까. (무언가 문제가 발생했다.)
# par(mfrow = c(4, 3))
# cate = c("교육", "미용", "서비스업", "오락 및 여가", "유통업", "음식소매업", "의료", "의류", "일반 음식점", "전자기기", "휴게 음식점")
# for (cat in cate) {
#   total %>%
#     filter(cate == cat) %>%
#     group_by(transacted_time) %>%
#     summarise(times = length(amount), .groups = "drop") %>%
#     ggplot() +
#     geom_point(aes(x = transacted_time, y = times)) +
#     xlab(cat) %>%
#     show
#   print(cat)
# }

# 으악 SQL 쓰고 싶다
# 아이디별로 다르게, refund = sum(amount < 0)
# 이건 되는데, for문 이용은 왜 안 되냐.
total %>% filter(cate == "일반 음식점") %>%
  group_by(store_id, transacted_time) %>%
  summarise(times = length(amount)) %>%
  ggplot(aes(color = store_id)) +
  geom_point(aes(x = transacted_time, y = times))
# length(unique(total[total$cate == "일반 음식점", "store_id"]))
