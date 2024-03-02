######## Transcriptome Analysis#######################

library(airway)
data("airway")
airway

colData(airway)
airway$cell
metadata(airway)
colnames(airway)
rownames(airway)

assayNames(airway)
assays(airway)

head(assay(airway,'counts'))

#length of genes in our data

rowRanges(airway)
dim(airway)
length(rowRanges(airway))


#number of exons

sum(elementNROWS(rowRanges(airway)))

start(airway)[[1]]
start(airway)
# how many genes exist in element 1 within a range of interest

gr<-GRanges(seqnames = '1',ranges = IRanges(start = 1,end=100000))
gr

subsetByOverlaps(airway,gr)

rowRanges(subsetByOverlaps(airway,gr))


#we can use dseq2 , limma and edgeR to analyze RNASeq



se<-airway  #Summerized Experiment

#remove genes with less than 5 counts

nrow(assay(se))
keep<-rowSums((assay(se))) >=5 #logical vector

se<- se[keep , ]
nrow(se)

#at leats 3 samples with counts of 10 or higher

keep<-rowSums(assay(se) >= 10) >= 3


se$dex
se$dex<-relevel(se$dex,"untrt")
colData(se)

#####Create a deseq object
library(DESeq2)
BiocManager::install("DESeq2")
dds<-DESeqDataSet(se ,design = ~ cell + dex)
dds$dex<-relevel(dds$dex,"untrt")# we already did this

#-------------from a count matrix-----------
countdata<-assay(se)
head(countdata, 3)
colData<- colData(se)

ddsMat<-DESeqDataSetFromMatrix(countData = countdata,colData=colData, 
                               design = ~cell+dex)


BiocManager::install("edgeR")
library(edgeR)

genetable<- data.frame(gene.id=rownames(se))
y<- DGEList(counts= countdata, samples= colData, genes= genetable)




vsd<-vst(dds) #variance stablizing transformation
class(vsd)

head(colData(vsd),3)

plotPCA(vsd, "dex")

plotPCA(vsd, intgroup= c('cell','dex'))


data<-plotPCA(vsd, intgroup= c('cell','dex'), returnData= TRUE )
percentvar<-round(100*attr(data, 'percentvar'))


library(ggplot2)
ggplot(data, aes(x=PC1,y=PC2,color=dex , shape= cell))+geom_point(size=3)+
  xlab(paste0("PC1:",percentvar[1],"% variance"))+
  ylab(paste0("PC2:",percentvar[2],"% variance"))

#generalized PCA for countdata

keep<- rowSums(counts(dds)>=10)>=3

dds<-dds[keep, ]
nrow(dds)

BiocManager::install("glmpca")
library(glmpca)
gpca<- glmpca(counts(dds), L=2)
gpca.dot<-gpca$factors
gpca.dot$dex<-dds$dex
gpca.dot$cell<-dds$cell

ggplot(gpca.dot,aes(x=dim1,y=dim2,color=dex,shape=cell))+geom_point(size=3)+
  coord_fixed()+ggtitle("GLMPCA")


#Multi dimensional scaling

library(magrittr)
mds<-as.data.frame(colData(vsd))%>% cbind(cmdscale(SDM))

ggplot(mds, aes(x=`1`,y=`2`,color=dex,shape=cell))+geom_point(size=3)+
  coord_fixed()+ggtitle('MDS with VSD data') 
#we used backtick for 1 & 2
#------sample distance
sampledist<-dist(t(assay(vsd)))

library(pheatmap)
library(RColorBrewer)

SDM<-as.matrix( sampledist )
rownames(SDM)<- paste(vsd$dex,vsd$cell,sep='-')
colnames(SDM)<-NULL
colors<-colorRampPalette(rev(brewer.pal(9,"Blues")))(255)
pheatmap(SDM,clustering_distance_rows = sampledist,clustering_distance_cols = sampledist,
         col = colors)
library(PoiClaClu)
poid<-PoissonDistance(t(counts(dds)))
Spoid<-as.matrix(poid$dd)
rownames(Spoid)<- paste(vsd$dex,vsd$cell,sep='-')
colnames(Spoid)<-NULL
pheatmap(Spoid,clustering_distance_rows = poid$dd,clustering_distance_cols = poid$dd,
         col = colors)


#---------DEGs

dds<-DESeq(dds)
res<-results(dds)
mcols(res,use.names=TRUE)

res<-results(dds,contrast = c("dex","trt","untrt"))
summary(res)

res.0.05<-results(dds,alpha=0.05,contrast = c("dex","trt","untrt"))
table(res.0.05$padj<.05)
relfc<-results(dds,lfcThreshold = 1  ,contrast = c("dex","trt","untrt"))
table(relfc$padj<.01)
#relfc<-results(dds,lfcThreshold = 1 ,alpha = 0.05 ,contrast = c("dex","trt","untrt"))

results(dds, contrast = c("cell","N061011","N61311"))




topgene<-rownames(res)[which.min(res$padj)]
plotCounts(dds, gene = topgene, intgroup = c("dex"))


library(ggbeeswarm)
geneCounts<-plotCounts(dds, gene = topgene, intgroup = c("dex"), returnData = TRUE)
ggplot(geneCounts,aes(x=dex, y= count, color=cell))+scale_y_log10()+geom_beeswarm(cex=3)

ggplot(geneCounts,aes(x=dex, y= count, color=cell))+scale_y_log10()+
  geom_beeswarm(cex=3)+geom_line()


#------MA plot
library(apeglm)
resultsNames(dds)
res<-lfcShrink(dds, coef = "dex_trt_vs_untrt",type = "apeglm")
BiocGenerics::plotMA(res, ylim=c(-5,5))










