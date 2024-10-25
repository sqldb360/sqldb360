import sys
import re

# 20240917 output in csv to be concat with escp output

def main(cpuFile):
    summaryList=list()
    fileName=re.findall('[a-z0-9\-]+',cpuFile)
    nodeName=fileName[3]
    dbName=fileName[4]
    kind="";
    nextLines=0
    productName=" "
    cpuName=" "
    cpuSpeed="0"
    cpuNum=1
 
    f = open(cpuFile,"r") 
    for line in f:

       if 'Intel' in line:
         kind="Intel"
       if 'PowerPC' in line:
         kind="IBM"
       if 'sparc' in line:
         kind="Sun"
       if 'AMD' in line:
         kind="AMD"

       if kind=='Intel':
         if nextLines==1:
          productName=line
         if "model name" in line:
          nextLines=1;
          if '@' in line:
             modelName=re.findall("(?<=:\s)(.*)(?=\s@)",line)
          elif ':' in line:
             modelName=re.findall("(?<=:\s)(.*)",line)
          else:
             modelName=[line]
          tokens = [ele for ele in re.findall("([0-9a-zA-Z-]+)",modelName[0]) if (len(ele) != 0) & (ele !="CPU") & (ele != "R") & (ele!='0') ]
          cpuName=cpuName.join(tokens)
          if "@" in line:
             cpuSpeed=str(int(float(re.findall('(?<=@\s)([0-9.]*)',line)[0])*1000))
          else:
             cpuSpeed='0'

       if kind=='IBM':
         if "Processor Type" in line:
            modelName=re.findall('(?<=:\s)(.*)',line)
            tokens=re.findall('[^_ ]+',modelName[0])
            cpuName=tokens[1]
         if "Number Of Processors" in line:
            cpuNum=re.findall('[0-9]+',line)[0]
         if "Processor Clock Speed" in line:
            cpuSpeed=re.findall('[0-9]+',line)[0]   

       if kind=='Sun':
         if nextLines==0:
          nextLines=1
          cpuNum=0
          tokens=re.findall('\w+',line)
          modelName=tokens[1]
          cpuName=tokens[1]
          cpuSpeed=tokens[5]
         if 'operates' in line:
          cpuNum=cpuNum+1  

       if kind=='AMD':
         if "model name" in line:
          cpuName=re.findall("AMD(?:\s[a-zA-Z0-9]+){2}",line)[0]
         else:
          productName=line 

       if kind=="":
         if nextLines==0:
          cpuName=line
         if nextLines==1:
          productName=line
         nextLines=nextLines+1

#    cmd="insert into cpuinfo_t(organization_id,nodeName,dbName,productName,cpuName,cpuSpeed,cpuNum) values(&&organization_id.,'"\
#    +nodeName.rstrip()+"','"+dbName.rstrip()+"','"+productName.rstrip()+"','"+cpuName.rstrip()+"',"+cpuSpeed.rstrip()+","+str(cpuNum)+");"    
#    print(cmd)
#          INSTANCE, INSTANCE_NAME   , 1   , 2024-04-01T10:20:12 , PREPROD1
    print("CPUINFO , PRODUCT_NAME    ,     ,                     , "+productName.rstrip())
    print("CPUINFO , CPU_NAME        ,     ,                     , "+cpuName.rstrip())
    print("CPUINFO , CPU_SPEED       ,     ,                     , "+cpuSpeed.rstrip())
    print("CPUINFO , CPU_NUM         ,     ,                     , "+str(cpuNum))

if __name__ == "__main__":
   main(sys.argv[1])
