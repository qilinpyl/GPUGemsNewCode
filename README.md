# GPU Gems New Code

# 说明
* 案例开发环境为 Windows 10 + Unity 2019.4.9f1 + Visual Studio 2019，其中 DirectX 12 版本的代码必须在 Windows 10 环境中才能运行，代码使用了龙书的代码框架。

# Chapter 1 Water Simulation
* 水面模拟一直是一个很难的话题，虽然 GPU Gems 是一本很老的教程，但是实现的水面效果还是很不错的。本案例中依次实现了两种形式的正弦近似值的加和、
圆形波和 Gerstner 四种波，其中公式均基于原书推导而得，在 Unity Shader 中可以很方便看出效果。几种波的对比如下：  
① 正弦波累加：这种波形比较圆润，而且如果将网格扩大范围会发现很多地方其实是重复的，可以应用在小池塘的风吹效果。  
② 正弦波累加的次方：这种波形是正弦波累加的优化，目的是让高度差更明显，但是还是存在重复的问题。  
③ 圆形波：这种波形也是相对圆润的波形，可以模拟在池塘上丢一块石头的效果。  
④ Gerstner 波：这种波形不仅高度差非常明显，而且在效果上观看不是很规律，适合模拟海洋这样粗犷的水面。

# Chapter 2 Water Caustics
* 水的焦散效果是一种很漂亮的效果，但是在书中和案例的代码中，都没有使用基于物理计算的焦散效果，都是一种大胆的假设，在一定程度上满足视觉体验。总体来说，我们实现焦散的步骤如下：  
① 创建两个 Pass，其中一个负责渲染水下的表面，另一个 Pass 负责水面计算。  
② 通过计算水面网格的顶点法线和平面的顶点法线，通过假想方程来计算“太阳”贴图的采样坐标。  
③ 渲染水面，并与平面颜色混合。  
整个过程对波浪和焦散的参数控制要求很高，因为假想方程很容易产生误差，基于现有的 Unity 技术，可以考虑使用投射器(Projector)来实现物理计算的焦散效果。
