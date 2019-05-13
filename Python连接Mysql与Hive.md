#### **在windows10上用impala+Python3.7连接mysql与hive数据库**

##### 1.安装python3.7或直接安装anaconda3，此处不过多介绍(推荐直接安装anaconda3）

##### First, you should install python3.7 or Anaconda3（Recommend), and I will not introduce how to install here.

##### 2.安装依赖包，使用pip安装下面6个依赖包时,4-6可能会出错，此时就用anaconda安装命令安装

##### Install dependency packages, and when you use pip install, it may have errors for thrift_sasl, thriftpy, impyla, and then you can use conda install. Make sure the version is right.

| 序号 |        包名 | 版本号 |                          安装命令行                          |     anaconda安装命令      |
| ---- | ----------: | :----: | :----------------------------------------------------------: | :-----------------------: |
| 1    |   pure_sasl | 0.5.1  | pip install pure_sasl==0.5.1 -i https://pypi.tuna.tsinghua.edu.cn/simple |                           |
| 2    |      thrift | 0.9.3  | pip install thrift==0.9.3 -i https://pypi.tuna.tsinghua.edu.cn/simple |                           |
| 3    |    bitarray | 0.8.3  | pip install bitarray==0.8.3 -i https://pypi.tuna.tsinghua.edu.cn/simple |                           |
| 4    | thrift_sasl | 0.2.1  | pip install thrift_sasl==0.2.1 -i https://pypi.tuna.tsinghua.edu.cn/simple | conda install thrift_sasl |
| 5    |    thriftpy | 0.3.9  | pip install thriftpy==0.3.9 -i https://pypi.tuna.tsinghua.edu.cn/simple |  conda install thriftpy   |
| 6    |      impyla | 0.14.1 | pip install impyla==0.14.1 -i https://pypi.tuna.tsinghua.edu.cn/simple |   conda install impyla    |

##### 3.运行程序   Run the code

```python
import matplotlib.pyplot as plt
import pandas as pd
import pymysql
import impala.dbapi as ipdb
#建立MYSQL数据库连接 Connect MySQL
conn = pymysql.connect(host='*****',port=3306,user='***',passwd='****',db='****')
print("MySQL连接成功")
mysql_s = pd.read_sql("select * from XXX",con=conn)
print(mysql_s)
#建立hive数据库连接，如果你是进入root用户后，需要登录其他用户进入hive，则此处user为该用户名；密码为登录linux的密码
#Connect hive, if you need to change other user name after login as root, the "user" need to be this name rather than "root", and the password need to be the password when you login
hiveconn=ipdb.connect(host="******",port=10000,user="hdfs",password="*****",database="*****",auth_mechanism='PLAIN')
cursor = hiveconn.cursor()
cursor.execute('select * from XXXX')
print(cursor.description)
for rowData in cursor.fetchall():
    print(rowData)`
conn.close()
```

##### 4.可能遇到的问题 The problems you may meet

###### 4.1提示语法错误  Problem 4.1

```python
Traceback (most recent call last):
  File "/Users/wangxxin/Documents/Python/PythonDataAnalyze/project/knDt/pyHiveTest.py", line 1, in <module>
    import impala.dbapi as ipdb
  File "/Users/wangxxin/miniconda3/lib/python3.7/site-packages/impala/dbapi.py", line 28, in <module>
    import impala.hiveserver2 as hs2
  File "/Users/wangxxin/miniconda3/lib/python3.7/site-packages/impala/hiveserver2.py", line 340
    async=True)
```

解决办法：将参数async全部修改为“async_”（当然这个可以随便，只要上下文一致，并且不是关键字即可），原因：在Python3.0中，已经将async标为关键词，如果再使用async做为参数，会提示语法错误；应该包括以下几个地方：
Suggestion: change the "async" to "async_" (anything you can change, ss long as the context is consistent and not the keyword)

```python
#hiveserver2.py文件338行左右
op = self.session.execute(self._last_operation_string,
                                  configuration,
                                  async_=True)
#hiveserver2.py文件1022行左右
def execute(self, statement, configuration=None, async_=False):
    req = TExecuteStatementReq(sessionHandle=self.handle,
                               statement=statement,
                               confOverlay=configuration,
                               runAsync=async_)
```

###### 4.2提供Parser.py文件有问题，加载时会报错   Problem 4.2 The Parser.py has problems

```python
#根据网上的意见对原代码进行调整
elif url_scheme in ('c', 'd', 'e', 'f'):
    with open(path) as fh:
        data = fh.read()
elif url_scheme in ('http', 'https'):
    data = urlopen(path).read()
else:
    raise ThriftParserError('ThriftPy does not support generating module '
                            'with path in protocol \'{}\''.format(
                                url_scheme))
```

###### 4.3继续运行，会报错   Problem 4.3

```python
TProtocolException: TProtocolException(type=4)
```

原因是由于connect方法里面没有增加参数auth_mechanism='PLAIN'
Because the function connect didn't add "auth_mechanism='PLAIN'", change it like that

```python
import impala.dbapi as ipdb
conn = ipdb.connect(host="192.168.XX.XXX",port=10000,user="xxx",password="xxxxxx",database="xxx",auth_mechanism='PLAIN')`
```

以上三个问题我都没有遇到，但是看网上很多人碰到，所以也整理了进来。
I didn't meet problems above, but I found many people met, so I put them together.

###### 4.4运行程序，可能会有下面错误 Problem 4.4

```python
AttributeError: 'TSocket' object has no attribute 'isOpen'
```

根据网上教程，发现是thrift-sasl的版本太高(0.3.0)，我一开始没有安装0.2.1版本，所以此处再次提醒大家thrift-sasl版本要降到0.2.1
This problem because the version of thrift-sasl is too high (0.3.0) and it should be 0.2.1 (I didn't install the right one first)

###### 4.5解决这个问题后，继续运行，发现报错    Problem 4.5

```python
thriftpy.transport.TTransportException: TTransportException(type=1, message="Could not start SASL: b'Error in sasl_client_start (-4) SASL(-4): no mechanism available: Unable to find a callback: 2'")
```

> I solved the issue, had to uninstall the package SASL and install PURE-SASL, when impyla can´t find the sasl package it works with pure-sasl and then everything goes well.

这个是因为sasl与pure-sasl冲突，直接卸载sasl包就行

```python
pip uninstall sasl
```

###### 4.6接着执行，发现还是报错（此时已经要完事了）  Problem 4.6  Now it's almost finished

```python
TypeError: can't concat str to bytes
```

定位到错误的最后一条，在init.py第94行（标黄的部分）
Find the error in init.py line 94 (The yellow part in console)

```python
header = struct.pack(">BI", status, len(body))
if (type(body) is str):
  body = body.encode()
self._trans.write(header + body)
self._trans.flush()
```

##### 至此，应该就可以正确连接2个库了   Now, you can connect mysql and hive.
