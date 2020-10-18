# GPU Gems New Code

# 说明
* 案例开发环境为 Windows 10 + Unity 2019.4.9f1，其中DirectX 12 版本的代码必须在 Windows 10 环境中才能运行。

# Chapter 1 Water Simulation
* 水面模拟一直是一个很难的话题，虽然 GPU Gems 是一本很老的教程，但是实现的水面效果还是很不错的。本案例中依次实现了两种形式的正弦近似值的加和、
圆形波和 Gerstner 四种波，其中公式均基于原书推导而得，在 Unity Shader 中可以很方便看出效果。
