# qwatch.d

## 出力例

```
$ qwatch.d
Your jobs:
        3127366
        3127367

Used logical CPUs by your jobs:
        nb-0089: 56/72
        nb-0094: 56/72
        nb-0245: 56/72
        nb-0276: 64/72
        nb-0436: 72/72
        nb-0437: 56/72
        nb-0479: 72/72
        nb-0545: 72/72
        nb-0559: 24/72
        nb-0573: 72/72
        nb-0584: 56/72

Total: 11 nodes and 656 logical CPUs are used by your jobs.
```


## インストール方法

1. 何らかの方法でD言語の処理系を入れておきます．

2. `$HOME/local/bin`などのディレクトリにスクリプトを保存し，実行権限を与えます．

```
cd $HOME/local/bin
wget https://raw.githubusercontent.com/k3kaimu/qwatch.d/master/qwatch.d
chmod +x qwatch.d
```
