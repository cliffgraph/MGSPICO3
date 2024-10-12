##ビルドの方法

```sh
> mkdir build
> cd build
> cmake -DPICO_PLATFORM=rp2350 -DPICO_BOARD=pico2 -G "NMake Makefiles" ..
> nmake
```
build/mgspico/に、mgspico_3.uf2　が生成される.

##ビルドの方法（もう少し詳しく）
（１）Developer PowerShell for VS 2019 を開く
（２）mgspico フォルダと同階層に、build フォルダを作成する。
（３）build フォルダへ移動する
（４）下記を実行する
	> set PICO_SDK_PATH "C:\Pico\pico-sdk"	*1
	> cmake -DPICO_PLATFORM=rp2350 -DPICO_BOARD=pico2 -G "NMake Makefiles" ..
（５）ビルド実行
	> nmake
（６）build\mgspico_3\ フォルダに、mgspico_3.uf2 ファイルが出来上がればOK。


*1: "C:\Pico\pico-sdk" は、pico-sdkを格納している場所へのパス。環境に合わせて変更すること。
    PowerShell の場合は、
		> $env:PICO_SDK_PATH="C:\Pico\pico-sdk"

以上

