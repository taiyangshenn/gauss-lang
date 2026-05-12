# 高斯语言（GaussLang）

一个极简的自举计算系统。内核50行C代码，4条指令，已验证自举闭环。

## 它是什么

- **4条指令**：PUSH / ADD / JZ / HALT
- **编译器**：递归复制生成器，编译时全展开所有分支
- **优化器**：伯恩赛德引理轨道压缩，自动消除冗余
- **自举验证**：编译器能处理自己的产物，形成语义闭环
- **汇编独立内核**：可脱离C库直接在CPU上运行

## 快速开始

编译并运行完整系统：

```bash
gcc -o gs_builder gs_builder.c && ./gs_builder

编译并运行汇编独立内核：
bash

gcc -nostdlib -static -o gs_kernel kernel_standalone.s
./gs_kernel ; echo $?

许可证

MIT License
作者

陈国营
