library(readr)
library(lubridate)
library(PerformanceAnalytics)

setwd("E:/factors_XuranZENG")
trading_data <- read_delim("data/trading data.txt", 
                           "\t", escape_double = FALSE, col_types = cols(Trdmnt = col_date(format = "%Y/%m/%d")), 
                           trim_ws = TRUE)
trading_data <- trading_data[order(trading_data$Stkcd),]

#kurtosis(trading_data$Mretwd)

##tradind datad���������Ѿ����µ׵����̼۳����³����̼�����˵ġ�����¶��������������1�ţ����������治��Ҫ����һ���·ݡ�
##����ÿ�����³����ֶ�Ӧ��ʮ����������,һ����ʮ���º����̼ۣ�һ����������
trading_data$Mclprc12m <-c(trading_data$Mclsprc[-(1:12)],NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA)
trading_data$Mretwd12m <- trading_data$Mclprc12m / trading_data$Mclsprc-1

data_length <- length(unique(trading_data$Stkcd))

kurtosis_factor<-data.frame(Stkcd = unique(trading_data$Stkcd),kurtosis=matrix(NA,data_length,1))


for(i in unique(trading_data$Stkcd)){
  
  data<-trading_data[which(trading_data$Stkcd==i),c(2,3,12)]
  
  kurtosis_factor[which(kurtosis_factor$Stkcd==i),2]<-kurtosis(data$Mretwd12m)
  
  }



##�Ե�һ����Ʊ��ʱ��Ϊ����ȡ����Ҫ���·ݵ�����
##seaport�Ǵ��������������ratio�Ƕ�ձ����Ĳ���
i <-1
ratio <- 0.2
nmonth <- 181
##nmonth��Ͷ�ʵ�������ricing_factor_data�ĵ�һ��Ҳ��ͷ��Ĵ���ʱ��
seaport <- data.frame(r_sa = matrix(NA,nmonth,1),r_vol = matrix(NA,nmonth,1),r_mvol= matrix(NA,nmonth,1),
                      r_group1 = matrix(NA,nmonth,1),r_group2 = matrix(NA,nmonth,1), r_group3 = matrix(NA,nmonth,1),
                      r_group4 = matrix(NA,nmonth,1),r_group5 = matrix(NA,nmonth,1), aof_group1= matrix(NA,nmonth,1),
                      aof_group2= matrix(NA,nmonth,1),aof_group3= matrix(NA,nmonth,1),aof_group4= matrix(NA,nmonth,1),
                      aof_group5= matrix(NA,nmonth,1))
##��һ���Ž�������ݿ�
results_des <- data.frame(SA = matrix(NA,6,1),VOL = matrix(NA,6,1),MVOL = matrix(NA,6,1),group1 = matrix(NA,6,1),
                          group2 = matrix(NA,6,1),group3 = matrix(NA,6,1),group4= matrix(NA,6,1), 
                          group5 = matrix(NA,6,1),row.names = c("MEAN","SD","SR","TSTAT","PVALUE","AOF"))
for (i in 1:nmonth){
  trading_lastmonth <- as.Date("2005-01-01")+months(i-1)
  trading_month <- as.Date("2005-01-01")+months(i)
  x <- trading_data$kurtosis_factor$kurtosis [trading_data$Trdmnt == trading_lastmonth]
  y <- trading_data$Stkcd [trading_data$Trdmnt == trading_month]
  #x�����Ӧ��������Ϣ��y����֤ȯ���룬���Ҫ�����ӣ��͸�x��Ӧ���о����ˡ�
  #ÿ���µ�ָ�꣬ɾȥNA���ڵ���
  y <- y[!is.na(x)]
  x <- x[!is.na(x)]
  stockn <- length(x)
  a <- stockn*ratio
  b <- stockn*(1-ratio)
  #���������Խ��Խ�ã�y[rank(x)<a]�Ǻ�30%����Ҫ���յ�֤ȯ���룬y[rank(x)>b]��ǰ30%Ҫ�����֤ȯ����
  #���������ԽСԽ�ã���ô���㷨������������ݵ�ʱ��Ҫ����-1
  #��һ��dataframe����ÿ���µĸ������ݡ�returns_short�ŵ��ǵ�i�ε��ֵĿ�ͷͷ��ĸ�����Ʊ������
  
  seashort <-data.frame(r= matrix(NA,length(trading_data$Mretwd[is.element(trading_data$Stkcd,y[rank(x)<a]) & trading_data$Trdmnt==trading_month]),1))
  #�����Ƕ�ͷ��ر��ʡ���Ʊ���롢����ֵ����ͨ��ֵ
  seashort$r <- trading_data$Mretwd[is.element(trading_data$Stkcd,y[rank(x)<a]) & trading_data$Trdmnt==trading_month] *(-1)
  seashort$tic <- trading_data$Stkcd[is.element(trading_data$Stkcd,y[rank(x)<a]) & trading_data$Trdmnt==trading_month]
  seashort$vol <- trading_data$Msmvttl[is.element(trading_data$Stkcd,y[rank(x)<a]) & trading_data$Trdmnt==trading_month]
  seashort$mvol <- trading_data$Msmvosd[is.element(trading_data$Stkcd,y[rank(x)<a]) & trading_data$Trdmnt==trading_month]
  
  sealong <- data.frame(r= matrix(NA,length(trading_data$Mretwd[is.element(trading_data$Stkcd,y[rank(x)>b]) & trading_data$Trdmnt==trading_month]),1))
  sealong$r <- trading_data$Mretwd[is.element(trading_data$Stkcd,y[rank(x)>b]) & trading_data$Trdmnt==trading_month]
  sealong$tic <- trading_data$Stkcd[is.element(trading_data$Stkcd,y[rank(x)>b]) & trading_data$Trdmnt==trading_month]
  sealong$vol <- trading_data$Msmvttl[is.element(trading_data$Stkcd,y[rank(x)>b]) & trading_data$Trdmnt==trading_month]
  sealong$mvol <- trading_data$Msmvosd[is.element(trading_data$Stkcd,y[rank(x)>b]) & trading_data$Trdmnt==trading_month]
  
  #��ÿ�����ȶ�Ӧ�����ּ�Ȩ����������������ʷ���seaprt��
  seaport$r_sa[i] <- (mean(seashort$r,na.rm=TRUE) + mean(sealong$r,na.rm=TRUE))
  seaport$r_vol[i] <- (mean(seashort$r*seashort$vol/sum(seashort$vol),na.rm=TRUE) + mean(sealong$r*sealong$vol/sum(sealong$vol),na.rm=TRUE))
  seaport$r_mvol[i] <- (mean(seashort$r*seashort$mvol/sum(seashort$mvol),na.rm=TRUE) + mean(sealong$r*sealong$mvol/sum(sealong$mvol),na.rm=TRUE))
  
  #��ָ�����5�ȷ֣���ƽ������
  seaport$r_group1[i] <- mean(trading_data$Mretwd[is.element(trading_data$Stkcd,y[rank(x)>(stockn *0.8)]) & trading_data$Trdmnt==trading_month],na.rm=TRUE)
  seaport$r_group2[i] <- mean(trading_data$Mretwd[is.element(trading_data$Stkcd,y[(rank(x)<(stockn *0.8)) & (rank(x)>(stockn *0.6))]) & trading_data$Trdmnt==trading_month],na.rm=TRUE)
  seaport$r_group3[i] <- mean(trading_data$Mretwd[is.element(trading_data$Stkcd,y[(rank(x)<(stockn *0.6)) & (rank(x)>(stockn *0.4))]) & trading_data$Trdmnt==trading_month],na.rm=TRUE)
  seaport$r_group4[i] <- mean(trading_data$Mretwd[is.element(trading_data$Stkcd,y[(rank(x)<(stockn *0.4)) & (rank(x)>(stockn *0.2))]) & trading_data$Trdmnt==trading_month],na.rm=TRUE)
  seaport$r_group5[i] <- mean(trading_data$Mretwd[is.element(trading_data$Stkcd,y[rank(x)<(stockn *0.2)]) & trading_data$Trdmnt==trading_month],na.rm=TRUE)
  
  seaport$aof_group1[i] <-mean(x[rank(x)>(stockn *0.8)])
  seaport$aof_group2[i] <-mean(x[(rank(x)<(stockn *0.8)) & (rank(x)>(stockn *0.6))])
  seaport$aof_group3[i] <-mean(x[(rank(x)<(stockn *0.6)) & (rank(x)>(stockn *0.4))])
  seaport$aof_group4[i] <-mean(x[(rank(x)<(stockn *0.4)) & (rank(x)>(stockn *0.2))])
  seaport$aof_group5[i] <-mean(x[rank(x)<(stockn *0.2)])
  
}

for (j in 1:8){
  results_des[1,j] <- mean(seaport[,j],na.rm = TRUE)*12
  results_des[2,j] <- sd(seaport[,j],na.rm = TRUE)*sqrt(12)
  results_des[3,j] <- results_des[1,j]/results_des[2,j]
  tresult <- t.test(seaport[,j],na.rm = TRUE)
  results_des[4,j] <- as.numeric(tresult$statistic)
  results_des[5,j] <- as.numeric(tresult$p.value)
}
for (j in 4:8){
  results_des[6,j] <- mean(seaport[,j+5],na.rm = TRUE)
}

#write.csv(seaport,file ="results\\liangjia\\momentum-portfolio.csv",)
#write.csv(results_des,file ="results\\liangjia\\momentum-result.csv",)