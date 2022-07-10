### A Pluto.jl notebook ###
# v0.19.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 826a4961-0f3a-4306-8661-864672d6d65e
begin
	using Pkg

	Pkg.activate(Base.current_project())
	Pkg.instantiate()
	
	using Mechanical
	
	using Unitful
	using Unitful: mm, cm, m, inch, N, kN, lbf, MPa, psi

	using PlutoUI
	
end;

# ╔═╡ c7b0ace0-c6a9-11ec-136e-bda63c76c62d
md"# How to calculate bolt loads within a bolt group

**Timothy Teske** 


A **bolt group** is a collection of fasteners through which loads (forces and moments) are reacted. The forces and moments acting on the bolt group self-distrubute to act on each individual bolt within the bolt group. The reaction force generated in each bolt will be comprised of tensile and shear forces.


The steps involved in calculating the individual bolt loads on fasteners within a bolt group are shown below:

1. Determine the x, y cooridnates of each bolt within the bolt group
2. Determine the centroid of the bolt group
3. Determine the loads (forces and moments) acting at the centroid of the bolt group
4. Distribute the loads on the bolt group centroid to each individual bolt

The focus of this notebook is:
* **Part 2:** Determine the centroid of the bolt group.
"

# ╔═╡ fb89c666-ec0d-4985-ae36-e6bf76bca4ef
md"## Centroid of a bolt group"

# ╔═╡ c2664507-1e96-4f58-b373-6b18a9a2f657
md"""
Bending and torsion acting on a bolt pattern tend to cause **rotation** to occur about the **centroid of the bolt group**. 

The bolt group centroid is analogous to the neutral axis of beam when subjected to bending or torsion. In a beam, bending and torsion stresses are generated about the neutral axis and in a bolt pattern, loads are developed about the bolt group centroid.

In a beam, the torsion stresses are highest the further you move away from the neutral axis. Likewise, in a bolt pattern, the bolt loads are highest the further you move away from the bolt centroid.
"""

# ╔═╡ 97cba576-cfc8-4185-9481-7aede2d2b5be
md"""
#### Torsion load applied to bolt pattern

To understand how bolt loads in a bolt pattern subjected to torsion change as the bolt centroid moves, consider a moment applied about a circular bolt pattern as per the figure below:



"""

# ╔═╡ 7f0767be-a410-42bb-9799-d320132113ff
 md"""
 ![test](https://github.com/tim-au/bolt_load_tutorials/blob/master/images/cylinder_cad_large.png?raw=true)

 """

# ╔═╡ 5f541773-61dd-4e1f-862c-2db5a48691e2
md"""
Given the parameters:

|Parameter | Value|
|:---- | :------: |
| PCD |450mm |
| Mz | 70kN.m |

The loads on the bolt pattern are summarised in the plot below:

"""

# ╔═╡ 820387e5-4237-4ce4-a934-b6b70a8fd3ea
begin
	p_example1 = circle(r=450mm/2, N=6)
	Fc_example1 = [0,0,0]N
	Mc_example1 = [0,0,70]kN*m
	plot_bolt_loads(p_example1, Fc=Fc_example1, Mc = Mc_example1)
end

# ╔═╡ 07725e27-1cdd-4d96-9679-bdadb4209f46
md"""

**Important Information to note from the plot above:**
- The centroid of the bolt pattern is indicated by the light grey circle centred at the grey cross hairs.
- The maximum axial load, `Amax` and maximum shear load, `Smax`, are shown at the top left of the plot .
- The value in square brackets after the value of `Amax` and `Smax` indicates which bolts in the bolt pattern experience the maximum axial and maximum shear load. In the plot above, all bolts (i.e. `[All]`) experience the same axial load magnitude (i.e. `0kN`) and the same shear load (i.e. `51.9kN`).
- The size of the arrows on the plot are proportional to the shear load acting on each bolt.
- The direction of the arrows on the plot represents the vectoral direction of the shear load acting on each bolt.
- The axial load in each bolt is indicated graphically by the fill colour of the hexagons representing each bolt in the bolt pattern (refer to color bar on the right of the plot).

You will see from the plot of the bolt loads above that the centroid is assumed to occur directly in the centre of the bolt pattern (i.e. at (0,0)). Later in this notebook you will see that if all bolts used are made from the same material and have the same stress area then the centroid will be located in the centre of the bolt pattern as shown above.

"""

# ╔═╡ 30f0b528-88f7-4402-9e38-8338543200f8
md"""
#### Impact of bolt centroid location: Torsion

Consider the bolt pattern and torsion loads (i.e. Mz) previously defined.

Observe the magnitude and direction of the bolt loads as the location of the bolt pattern centroid changes: 

"""

# ╔═╡ b3ae2dfa-976b-4307-988e-c55c6779f2c8
begin
md"""

**Change the bolt pattern centroid Location (xc, yc) using the sliders below:**

| xc | yc |
|:---: | :---: |
|$(@bind x_pivot Slider(-140:5:140, default=0)) | $(@bind y_pivot Slider(-140:5:140, default=0)) |

"""
end

# ╔═╡ 6d6a4734-6154-4f36-b27d-a7c9a29ea779
begin
	
	#pivot2 = [100, 100]mm
	pivot2 = [x_pivot, y_pivot]mm
	plot_bolt_loads(p_example1, Fc=[0, 0, 0]N, Mc = Mc_example1, udf_pivot = pivot2)
end

# ╔═╡ 75ea1665-5fc2-4606-ab24-a60fa9a22676
begin
	df1 = bolt_loads(p_example1, Fc=Fc_example1, Mc = Mc_example1, udf_pivot = pivot2)
	filter1 = df1.Pshear .== maximum(df1.Pshear)
	Pshear_max1 = maximum(df1.Pshear)

	if pivot2[1] == 0mm && pivot2[2] == 0mm
		id_max1 = "All"
	else
		id_max1 = maximum(filter1 .* collect(1:length(filter1)))
	end
	
end;

# ╔═╡ 712e5f73-21ab-41ab-941a-85d6a20d7d95
md"""
#### Bending load applied to bolt pattern

To understand how loads on bolts within a bolt pattern subjected to bending change as the bolt centroid moves, consider a moment applied about a rectangular plate and bolt pattern as per the figure below:



"""

# ╔═╡ b524dfec-2229-4979-a240-aca38555c670
 md"""
 ![t-bracket all](https://github.com/tim-au/bolt_load_tutorials/blob/master/images/t-bracket_all_large4.png?raw=true)

 """



# ╔═╡ 1d92d63a-1791-4078-912e-cdf52d0d560c
md"""
- If the base plate has a low stiffness (i.e. is thin or made from material with low Modulus of Elasticity) then the base plate will tend to bend relatively close to the application of the bending moment `P*h1`. 
- Bending could occur anywhere along the base plate. The actual location that plate begins to bend will depend on the stiffness of the baseplate.
- The stiffness of the baseplate is dependent on its material properties (Modulus of Elasticity) and geomerty (i.e. thicker plate likely a stiffer plate).
- A **low stiffness base plate** may start to **bend about `BB'`** as per (1) in the figure above.
- A **high stiffness base plate** may start to **bend about `DD'`** as per (2) in the figure above.
- In reality, bending may occur anywhere between BB' and EE' dependent on the stiffness of the base plate.

"""

# ╔═╡ 24bb8e96-cc26-4803-8f57-12270bb24ded
md"""

When a bolt pattern is subjected to bending, the centroid of the bolt pattern defines the `pivot axis` (also referred to as the `hinge axis`) of the bolt pattern. The centroid is dependent on the stiffness of the material it is securing as discussed above. Usually engineers make conservative assumptions about where the `pivot axis` is located as we will see in future notebooks. If a less conservative approach needs to be taken then the engineer may need to undertake a Finite Element Analysis to determine the location of bending and bolt load reactions.

"""

# ╔═╡ cea00363-6079-48b1-a92f-5822eb9cb412
md"""
#### Impact of bolt centroid location: Bending

Consider the bolt pattern subject to beding (and shear) loads previously defined. Assume the following parameters:

| Paramater | Value |
| :--- | :---: |
| P | 7000N |
| h1 | 120mm |
| L1 | 200mm |
| W | 600mm |

Observe the magnitude and direction of the bolt loads as the location of the bolt pattern centroid changes: 

"""

# ╔═╡ 84f0d98c-1563-4a2a-adbf-71663254708d
md"""

**Move the pivot axis between BB' and DD' using the sliders below:**

|  |  | |
|:---: | :---: | :---:|
|BB`|$(@bind x_pivot_3 Slider(-100:5:300, default=-100)) | DD`|

"""

# ╔═╡ 6027190c-4130-47e2-8f34-69abf889e06c
begin
	P_3 = 7000N
	h1_3 = 120mm
	L1_3 = 200mm
	W_3 = 600mm
	pivot3 = [x_pivot_3*mm, 0mm]
	p3 = rectangle(x_dist=W_3, y_dist = L1_3, Nx=2, Ny=2)
	plot_bolt_loads(p3, Fc=[P_3, 0N, 0N], Mc = [0N*m, P_3*h1_3, 0N*m], udf_pivot = pivot3, load_format = "N")
end

# ╔═╡ 9073dd0d-5c1b-4182-911a-1929940ccee0
md"## 2. Calculate the centroid of the bolt group
The second step in determining bolt loads on the bolt group is to determine the centoid of the bolt group.

Loads (forces and moments) acting on a bolt group will tend to act about the bolt centroid. The bolt centroid can be thought of as the point that the bolt group pivots about when the loads are applied.

The formula for calculating the bolt centroid $x_c$ and $y_c$ is:

$x_c = \frac{\sum_i{x_iA_i}}{\sum_i{A_i}}    \qquad  \qquad y_c = \frac{\sum_i{y_iA_i}}{\sum_i{A_i}}$

"

# ╔═╡ 4e81e565-0be2-455d-b74f-fe6b6fae43a0
md"""Consider the x and y coordinates of a bolt pattern as shown below; the same fastener type is used for all bolts in the bolt pattern (i.e. the area for all bolts used is the same):

Bolt ID | x [mm] | y [mm]
:------------: | :-------------: | :-------------:
1 |-150 | -30
2 | -110 | 60
3 | -55 | 150
4 | 66 | 220
5 | 110 | -44
6 | 150 | -95

"""

# ╔═╡ ac412446-c094-43a4-9ccf-7ee5e8750d5c
md"We can manually enter the bolt pattern points as an x & y vector to enable further analysis; we enter the values for the x & y vectors from Bolt 1 to Bolt 6:"

# ╔═╡ d4e352b6-655b-4c34-838a-2697b877b7d8
x1 = [-150, -110, -55, 66, 110, 150]mm

# ╔═╡ 7769348e-b850-42ab-96c0-ed68e5fa22d1
y1 = [-30, 60, 150, 220, -44, -95]mm

# ╔═╡ f6f37c90-54b3-4a81-ae6f-2a645af3636e
md"We can package the x & y vectors together to make further analysis with built-in functions relatively simple:"

# ╔═╡ 11413d0e-04db-41d6-b7d2-c7a6ca06cbe6
p1 = x1, y1

# ╔═╡ e091451e-d9ec-400c-8130-913f65be017d
md"""As the same bolt type is used for all fasteners in the bolt pattern, the equation for determining the bolt centroid simplifies to:

$x_c = \frac{\sum_i{x_i}}{\sum_i{i}}    \qquad  \qquad y_c = \frac{\sum_i{y_i}}{\sum_i{i}}$

where $i$ is the _ith_ bolt in the bolt pattern.
"""

# ╔═╡ 43bd3fab-4c98-42f7-8217-dd0aeb3be6f9
md"""Calculating the centroid of the bolt pattern described above:"""

# ╔═╡ 4adcd9dd-cbd0-4e5d-bbcc-65976092a128
xc1 = ((-150 -110 -55 +66 +110 + 150) / 6)mm

# ╔═╡ b6304e82-edc4-41fa-9bf3-e4ee6abd34d0
yc1 = ((-30 + 60 + 150 + 220 -44 -95) / 6)mm

# ╔═╡ ae9402a0-3fd6-488a-80e3-fd44e0617cff
md"#### Exercise 🤔
**Manually calculate the values of the centroid `xc2` and `yc2` for the bolt pattern as described in the table below; all bolts in the pattern are the same type:**


Bolt ID | x [mm] | y [mm]
:------------: | :-------------: | :-------------:
1 |-160 | -80
2 | -110 | 20
3 | 80 | 101
4 | 188 | 87
5 | 221 | -35
6 |300 | -99
7 |340 | 42
8 | 350 | 110


"

# ╔═╡ f64dc4dc-7e23-4da0-bf0b-83615fcb8814
begin
	x22 = [-160, -110, 80, 188, 221, 300, 340, 350]mm
	y22 = [-80, 20, 101, 87, -35, -99, 42, 110]mm
	plot_bolt_pattern((x22, y22))
end

# ╔═╡ 85dfcd0c-a2b4-411a-a70e-40601e060923
xc2 = "complete these details..."

# ╔═╡ d87ca29f-2ea4-4fa7-ab73-3758f9b16598
yc2 = "complete these details..."

# ╔═╡ d4443332-d349-41ed-9ab0-6964f7af1e0c
md"""**Manually calculate the values of the centroid `xc3` and `yc3` for the bolt pattern as described in the table below; all bolts in the pattern are the same type:**


Bolt ID | x [inch] | y [inch]
:------------: | :-------------: | :-------------:
1 |-4.25 | -2.75
2 | -3.25 | -3.5
3 | 2.75 | 2
4 | 4 | 3.75
5 | 4.75 | 3.75
6 |5 | -3.5
7 |8 | -4
8 | 8.75 | 4.75


"""

# ╔═╡ b428217a-0293-4f5f-b5a2-23374f4dd015
xc3 = "complete these details..."

# ╔═╡ 76f8e86a-f4cd-4bd2-81bb-887ae7e30df6
yc3 = "complete these details..."

# ╔═╡ 60b4824f-4a38-4ee4-a18f-354bc052779f
md"""**Manually calculate the values of the centroid `xc4` and `yc4` for the bolt pattern as described in the table below; all bolts in the pattern are the same type:**


Bolt ID | x [cm] | y [cm]
:------------: | :-------------: | :-------------:
1 |-320 | 120
2 | -275 | -70
3 | -110 | 180
4 | -50 | 220
5 | -10 | -66
6 |30 | -150
7 |50 | 80
8 | 80 | 0
9 | 120 | -30


"""

# ╔═╡ 3c3f2ff7-8911-43ec-94e6-e7d060bf5acc
xc4 = "complete these details..."

# ╔═╡ 0c93dff1-1abd-4a7e-ade7-ab490e154336
yc4 = "complete these details..."

# ╔═╡ 88f185e1-307d-497a-bb71-4d67080c65b6
md"To plot the bolt pattern, you can use the function `plot_bolt_pattern`.

For example, to plot the bolt pattern for the points `p2` that you just entered, type the following into the cell bellow and press `Run cell` to evaluate:

* `plot_bolt_pattern(p2)`"

# ╔═╡ 0f95ebb8-6db9-40b5-ab16-4759eab46df7
md"**[Ex 1.2] Generate a plot for the bolt pattern p2:**"

# ╔═╡ 28256565-ce91-468c-a891-5548f02acc3b
"create the plot for bolt pattern p2 here ..."

# ╔═╡ b929203f-3418-4ef8-a33c-190e6e8e317f
md"You can also enter coordinates in various unit systems such as `mm`, `cm`, `m`, `inch`:"

# ╔═╡ 5919f304-1b58-44a8-b589-750251897375
a2 = 2.0inch

# ╔═╡ 8b28a0c4-82c0-4526-87b8-dd792278625d
md"If you enter multiple units into a vector, then it will automatically convert the vector into SI units - _meters for length SI units_"

# ╔═╡ 5884513e-7633-468f-8002-7e6a48a0c88a
b2 = [2inch, 3cm, 0.1m, 120mm]

# ╔═╡ 0a5fff1f-893c-4817-9e9a-31f353e88466
md"To convert to a different unit, you can use the pipe operator `|>` in julia:"

# ╔═╡ 70429b94-3802-462a-9e15-1da1c2410c03
a2 |> mm

# ╔═╡ a1ad0689-abe5-4f7c-8f50-e0685b3aaaf9
a2 |> cm

# ╔═╡ 99f0a709-8a6c-43f7-b651-12aa770e8c61
md"Vector operations in julia require you to use a `.` operator when you need to perform operations to each element of the vector - otherwise julia will automatically perform matrix operations.

For example:"

# ╔═╡ 5ec428fb-fd9b-4a07-9c06-e649708cdb83
b2 .|> mm

# ╔═╡ e81d199d-3888-4178-86e4-36760457f304
b2.^2

# ╔═╡ f3f65c4e-80bb-44cc-a0fa-12efca19f50d
b2.^2 .|> inch^2

# ╔═╡ 6bd5d895-e2ea-4d2d-870c-e1556facee6e
sin.(b2 ./ 1inch) + cos.(b2.^2 ./ 1cm^2)

# ╔═╡ 9336e2e7-f75b-4313-94fb-fdf7117796c9
md"Instead of using the `.` operator everywhere to denote that you would like to perform operations on each element of the vector, you can use the `@.` operator once after the `=` sign:"

# ╔═╡ 86da409a-1451-4093-bf72-67781e3679ac
@. b2 |> mm

# ╔═╡ 731e4eb8-b90e-425e-9bca-028ee58c8dd1
md"or:"

# ╔═╡ a66dcc0b-ce43-4eef-8b4b-c9d425c194bf
b2_new = @. b2 |> mm

# ╔═╡ 4ed4b8eb-63d6-41d4-963d-32d766350982
@. b2^2

# ╔═╡ 9f891a05-64e7-495f-9d75-4a4de2fd2607
@. b2^2 |> inch^2

# ╔═╡ b165ee67-c0e0-49b5-834a-20150b94af75
@. sin(b2 / 1inch) + cos(b2^2 / 1cm^2)

# ╔═╡ 11762102-f44a-4bae-b618-4d110e532522
md"#### Exercise 🤔

**[Ex 1.3] Determine the value of  `theta`  by converting  `theta_deg`  into radians:**

Note1: When dealing with degrees and radians we don't use units; the values are entered unitless.

Note2: Mathematical functions and constants can be entered directly in julia. For example you can use:
* `sin`, `cos`, `tan`, `pi` 
* Use the `Live docs` on the right to search for many more mathematical functions included in `julia`
"

# ╔═╡ 0d25abea-e440-4757-9565-8a2e77685ded
theta_deg = LinRange(0, 360, 9)

# ╔═╡ 29554cd2-7ae0-4147-9303-d4117f887e8b
theta = "complete these details by converting theta into radians..." 

# ╔═╡ 7ea552f2-0a46-4e1a-a0e4-46998f77c47b
md"**[Ex 1.4] Now calculate the value of `x3`.**

Where `x3` is:

$x_3 = 2\sin{\theta} + 3\cos{\theta} + 5\sin^2(\theta)cos^3(\theta + \frac{\pi}{4})$

(all units are in `cm`)
"

# ╔═╡ 953090eb-dc96-4e17-b9e8-23f72f5c77b3
x3 = "complete these details..."

# ╔═╡ ff45ee57-8a5e-4520-8b10-2238fff67076
md"**[Ex 1.5] Now convert the value of x3 into inches:**"

# ╔═╡ e529f320-de94-49ae-b2e4-61233193fb89
x3_inch = "complete these details..."

# ╔═╡ 2aa05c08-ae3a-4fa9-8d12-729f918130ab
md"### Rectangular bolt pattern
Consider a base plate with a square bolt pattern comprised of four fasteners (`Nx` = 2 and `Ny` = 2; number of fasteners in x and y directions). 

The width `x_dist` of the bolt pattern is 200 mm.
The height `y_dist` of the bolt pattern is 120 mm.
"

# ╔═╡ 5cadc8cd-6821-4e8f-9976-84a729029675
md"The x and y coordinates of the bolt pattern are: "

# ╔═╡ 3732453b-cf67-4087-8bca-f048b0ed81a2
p4 = x4, y4 = rectangle(x_dist = 200mm, y_dist = 120mm, Nx = 2, Ny = 2)

# ╔═╡ acc8a1ab-2da1-4112-803a-13b957a44206
md"A plot of the bolt pattern showing the x & y coordinates is shown below.
"

# ╔═╡ 13e28629-e8da-4f8f-beb9-13bdb2d47df5
plot_bolt_pattern(p4)

# ╔═╡ 79307eba-ac13-4abe-9dca-2312d322e931
md"Points can be entered in various units such as `mm`, `cm`, `m` and `inch`.

Consider a bolt pattern with `3` fasteners in the x-direction and `5` in the y-direction.

The width of the bolt pattern in `7.5 inches`, and the height of the bolt pattern in `5.25 inches`.

"

# ╔═╡ 842e570e-9b8b-45f7-b22c-4811512835e2
p5 = rectangle(x_dist = 7.5inch, y_dist = 5.25inch, Nx = 3, Ny = 5)

# ╔═╡ b96d0fa2-bc1b-4c9d-848a-a58ffd44f448
md"Plotting the bolt pattern for points `p2`:"

# ╔═╡ 914b6207-7388-4d65-9a79-5363f3bf45b5
plot_bolt_pattern(p5)

# ╔═╡ b6af4611-2b06-42e6-91d3-4eec372eeb1e
md"#### Exercise 🤔
Generate the coordinates for a rectangular bolt pattern:
* width equal to 350 mm
* height equal to 220 mm.
* 3 fasteners in the x-direction
* 4 fasteners in the y-direction.
"

# ╔═╡ 37aafa42-5ee3-420d-bb2e-8980c3288272
md"**[Ex 1.6] Complete the function for determining the coordinates `p6` below:**"

# ╔═╡ 1ca1f4b3-24a2-4d91-bf89-9eb3802d24b5
p6 = "complete these details ..."

# ╔═╡ 98a230ec-25bf-4e77-aab5-20bc6b69d32b
md"**[Ex 1.7] Generate a plot for the bolt pattern p6:**"

# ╔═╡ d268b813-0ee8-4d9c-abe8-b565c38ead8e
"create the plot for bolt pattern p6 here ..."

# ╔═╡ 7a094d01-7906-4c8f-8a26-627f1558f0e6
md"### Circular bolt pattern
Consider a base plate with a square bolt pattern comprised of six fasteners distributed around a diameter of 250mm:
"

# ╔═╡ eabeac06-3adc-4384-bee4-5a11d8b9d422
p7 = circle(r=250mm/2, N=6)

# ╔═╡ 86519046-8e69-4c66-812d-d9bbb074f7cc
md"A plot of the bolt pattern showing the x & y coordinates is shown below.

Hover over each bolt in the plot below to observe the x, y coordinates of each bolt.
"

# ╔═╡ 2872d214-0db8-48b9-9280-d2554495e108
plot_bolt_pattern(p7)

# ╔═╡ 2217bab6-00a4-4fb5-9950-5ed9f717ad38
md"""Now consider the circular bolt pattern with 
* Pitch Circle Diameter (PCD) = 360mm
* 3 fasteners in the bolt pattern
* first bolt in the pattern starts at 45 degrees from the positive y-axis

"""

# ╔═╡ 7e5439ae-c9f4-43c3-af0a-adb1084b549b
p8 = circle(r=360mm/2, N=3, theta_start = 45)

# ╔═╡ 0420b357-850c-4d92-809b-c22d6f091010
plot_bolt_pattern(p8)

# ╔═╡ 8d10edcc-f6d7-459f-8464-204352fb56ab
md"""Now consider the circular bolt pattern with 
* Pitch Circle Diameter (PCD) = 360mm
* 3 fasteners in the bolt pattern
* first bolt in the pattern starts at 90 degrees from the positive y-axis (i.e. first fastener in bolt pattern is located on positive x-axis)

"""

# ╔═╡ 914717da-e086-442c-bbf7-b7548125b038
p9 = circle(r=360mm/2, N=3, theta_start=90)

# ╔═╡ 51b1d76e-9ddf-4524-b560-e69900bee55f
plot_bolt_pattern(p9)

# ╔═╡ da511c9c-391a-4258-96f9-00ee38f95a92
md"#### Exercise 🤔
**[Ex 1.8] Generate the coordinates for a circular bolt pattern:**
* PCD = 420mm
* Number of fasteners in pattern = 7
* first fastener in pattern lies on positive y-axis
"

# ╔═╡ 844b08df-6e28-4476-b1e7-2108752d5c27
p10 = "complete these details ..."

# ╔═╡ fd14bf64-dce1-46db-8e2d-d95b8f467406
md"**[Ex 1.9] Generate a plot for the bolt pattern p10:**"

# ╔═╡ 8dd9436b-911e-4573-a9ed-feafe24b7061
"create the plot for bolt pattern p10 here ..."

# ╔═╡ ae571d48-b21a-4002-9f5c-274cbf142c7a
md"
**[Ex 1.10] Generate the coordinates for a circular bolt pattern:**
* PCD = 6.25inch
* Number of fasteners in pattern = 5
* first fastener in pattern lies 30 degrees measured clockwise from the  positive y-axis
"

# ╔═╡ 570ca407-96a9-4e21-923f-971bebfc1258
p11 = "complete these details ..."

# ╔═╡ 27d6a970-5212-41fa-8c5f-45910c0aad65
md"**[Ex 1.11] Generate a plot for the bolt pattern p11 here**"

# ╔═╡ cefe71ef-d2fa-4258-9e67-250d7f6c0959
"create the plot for bolt pattern p11 here ..."

# ╔═╡ 795c01ba-60b9-4af9-b1e9-bf0de27f590c
md"
**[Ex 1.12] Generate the coordinates for a circular bolt pattern:**
* radius = 11.7cm
* Number of fasteners in pattern = 6
* first fastener in pattern lies 37 degrees measured anticlockwise from the  positive x-axis
"

# ╔═╡ 465439e9-ea8f-4fea-974f-81cd0579c38c
p12 = "complete these details ..."

# ╔═╡ dde68756-7ccb-4fb8-aad5-93bfdb786a93
"";

# ╔═╡ eec721fb-8d4d-49ac-a331-daf919f72f23
"";

# ╔═╡ 6ad68ec4-e762-4f0d-b959-d40e556d8a06
"";

# ╔═╡ 0afc7172-c3d5-4731-93ec-40a97476dab6
"";

# ╔═╡ 8beb7ffd-4627-4350-8117-356dae98884d
"";

# ╔═╡ f4760cb3-c270-4dfc-b589-d90cfb1a7031
begin

	# Functions for for providing feedback on exercises
	
	hint(text) = Markdown.MD(Markdown.Admonition("hint", "Hint", [text]));

	almost(text) = Markdown.MD(Markdown.Admonition("warning", "Almost there!", [text]));

	keep_working(text=md"The answer is not quite right.") = Markdown.MD(Markdown.Admonition("danger", "Keep working on it!", [text]));

	correct(text=md"Great! You got the right answer! Let's move on to the next section.") = Markdown.MD(Markdown.Admonition("correct", "Got it!", [text]));
end;

# ╔═╡ 5a9d2343-d366-4504-87ef-ce4e1de959fb
begin

	# Cheaters cash out early and consequently miss out on the spectacular long term gains... :)

	norm(a) = sqrt(sum(a.^2))

	function ex1_1()
		if p2 == p_1_1
			correct(md"""**Great!**  You figured it out.  Keep going.""")
		else
			hint(md""""Don't forget to enter the values for the coordinates starting with the point on the left and moving to the right.

			Make sure you press the `Run cell` button located at the right of each cell to evaluate the results. (If the `Run cell` button cannot be found in your browser, you may need to press `shift` + `enter` to evaluate each cell).
			

			Make sure you add units to the vector:
			
			i.e. 
			
			x2 = [... , ..., ..., ..., ...]mm

			y2 = [... , ..., ..., ..., ...]mm

			
			""")
		end
	end

	function ex2_2a()
		a2_2 = @. theta_deg * π / 180
		if typeof(theta) == String
			hint(md""""Don't forget to apply the `.` operator to each function or the `@.` operator after the `=` sign.
			""")
		elseif norm(theta - a2_2) < 0.1
			correct(md"""**Great!**  You figured it out.  Keep going.""")
		else
			hint(md""""Don't forget to apply the `.` operator to each function or the `@.` operator after the `=` sign.
			""")
		end
	end

	function ex2_2b()
		
		if typeof(x3) == String
			hint(md"""Don't forget to apply the `.` operator to each function or the `@.` operator after the `=` sign.

			Don't forget to use units, 

			i.e. x3 = 2cm\*(...) + 3cm\*(...) + 5cm\*(...) """)
			
		else
			a2_2b = @. 2cm*sin(theta) + 3cm*cos(theta) + 5cm*(sin(theta))^2*(cos(theta + pi/4))^3

			if norm(ustrip(x3) - ustrip(a2_2b)) < 0.1
				correct(md"""**Great!**  You figured it out.  Keep going.""")
			else
				hint(md"""Don't forget to apply the `.` operator to each function or the `@.` operator after the `=` sign.
	
				Don't forget to use units, 
	
				i.e. x3 = 2cm\*(...) + 3cm\*(...) + 5cm\*(...) """)
			end
		end

	end
	

	function ex2_2c()

		if typeof(x3_inch) == String
			hint(md"""Have you included `cm` units on x3 already? To convert to inches make sure that you use the `.` operator or `@.` operator.""")
		else
			a2_2b = @. 2cm*sin(theta) + 3cm*cos(theta) + 5cm*(sin(theta))^2*(cos(theta + π/4))^3
			a2_2c = a2_2b .|> inch
			if norm(ustrip(x3_inch) - ustrip(a2_2c)) < 0.1
				correct(md"""**Great!**  You figured it out.  Keep going.""")
			else
				hint(md"""Have you included `cm` units on x3 already? To convert to inches make sure that you use the `.` operator or `@.` operator.""")
			end
		end
	end
	
	function ex1_3()
		if p6 == rectangle(x_dist = 350mm, y_dist = 220mm, Nx = 3, Ny = 4)
			correct(md"""**Great!**  You figured it out.  Keep going.""")
		else
			hint(md""""You will need to type in the details of the `rectangle` function.
	
			For example: **p6 = rectangle(...)**

			If you can't recall what the keyword arguments for `rectangle` function, you can type _rectangle_ in the `Live docs` toolbar shown on the right.
			""")
		end
	end


	function exp10()
		if p10 == circle(r=420mm/2, N=7)
			correct(md"""**Great!**  You figured it out.  Keep going.""")
		else
			keep_working()
		end
	end


	function exp11()
		if p11 == circle(r=6.25inch/2, N=5, theta_start=30)
			correct(md"""**Great!**  You figured it out.  Keep going.
			
			Only one more problem to go and then you are finished !!!""")
		else
			keep_working()
		end
	end


	function exp12()
		if p12 == circle(r=11.7cm, N=6, theta_start=90-37)
			correct(md"""**Fantastic!**  You completed everything !!!.
			
			Now save this file as HTML or PDF document by clicking the export triangle on the top right of this page (it should appear when you hover your mouse in the top right section of this page).

			**To collect your prize:**
			
			Return your notebook to that genuinely friendly bloke - the guy who wants to help you succeed, that brilliant TIG welder, the mountain bike rider extraordinaire and inventor. ...  need I say more - you know who he is :)
			
			!!! """)
		else
			keep_working()
		end
	end
	
	
end;

# ╔═╡ ddc9648c-0704-4615-aeaf-2673d5f903b2
ex1_1()

# ╔═╡ b2f090c1-5a77-4132-8383-85c280f5915b
ex2_2a()

# ╔═╡ e6573104-1a1e-42e4-bf76-65d71d2a418c
ex2_2b()

# ╔═╡ 9c770f5d-1447-4bd1-9a5c-8ac486cf394c
ex2_2c()

# ╔═╡ 4f51e99c-a822-4667-a485-75f6b48f6287
ex1_3()

# ╔═╡ 59095d92-89d9-453f-a3ef-c471126c667f
exp10()

# ╔═╡ 8fea754e-6061-4943-b1fc-9fd645b75875
exp11()

# ╔═╡ cf31336f-f05a-459e-9082-dfcba1006718
exp12()

# ╔═╡ Cell order:
# ╟─c7b0ace0-c6a9-11ec-136e-bda63c76c62d
# ╟─826a4961-0f3a-4306-8661-864672d6d65e
# ╟─fb89c666-ec0d-4985-ae36-e6bf76bca4ef
# ╟─c2664507-1e96-4f58-b373-6b18a9a2f657
# ╟─97cba576-cfc8-4185-9481-7aede2d2b5be
# ╟─7f0767be-a410-42bb-9799-d320132113ff
# ╟─5f541773-61dd-4e1f-862c-2db5a48691e2
# ╟─820387e5-4237-4ce4-a934-b6b70a8fd3ea
# ╟─07725e27-1cdd-4d96-9679-bdadb4209f46
# ╟─30f0b528-88f7-4402-9e38-8338543200f8
# ╟─75ea1665-5fc2-4606-ab24-a60fa9a22676
# ╟─6d6a4734-6154-4f36-b27d-a7c9a29ea779
# ╟─b3ae2dfa-976b-4307-988e-c55c6779f2c8
# ╟─712e5f73-21ab-41ab-941a-85d6a20d7d95
# ╟─b524dfec-2229-4979-a240-aca38555c670
# ╟─1d92d63a-1791-4078-912e-cdf52d0d560c
# ╟─24bb8e96-cc26-4803-8f57-12270bb24ded
# ╟─cea00363-6079-48b1-a92f-5822eb9cb412
# ╠═6027190c-4130-47e2-8f34-69abf889e06c
# ╠═84f0d98c-1563-4a2a-adbf-71663254708d
# ╟─9073dd0d-5c1b-4182-911a-1929940ccee0
# ╟─4e81e565-0be2-455d-b74f-fe6b6fae43a0
# ╟─ac412446-c094-43a4-9ccf-7ee5e8750d5c
# ╠═d4e352b6-655b-4c34-838a-2697b877b7d8
# ╠═7769348e-b850-42ab-96c0-ed68e5fa22d1
# ╟─f6f37c90-54b3-4a81-ae6f-2a645af3636e
# ╠═11413d0e-04db-41d6-b7d2-c7a6ca06cbe6
# ╟─e091451e-d9ec-400c-8130-913f65be017d
# ╟─43bd3fab-4c98-42f7-8217-dd0aeb3be6f9
# ╠═4adcd9dd-cbd0-4e5d-bbcc-65976092a128
# ╠═b6304e82-edc4-41fa-9bf3-e4ee6abd34d0
# ╟─ae9402a0-3fd6-488a-80e3-fd44e0617cff
# ╠═f64dc4dc-7e23-4da0-bf0b-83615fcb8814
# ╠═85dfcd0c-a2b4-411a-a70e-40601e060923
# ╠═d87ca29f-2ea4-4fa7-ab73-3758f9b16598
# ╟─d4443332-d349-41ed-9ab0-6964f7af1e0c
# ╠═b428217a-0293-4f5f-b5a2-23374f4dd015
# ╠═76f8e86a-f4cd-4bd2-81bb-887ae7e30df6
# ╟─60b4824f-4a38-4ee4-a18f-354bc052779f
# ╠═3c3f2ff7-8911-43ec-94e6-e7d060bf5acc
# ╠═0c93dff1-1abd-4a7e-ade7-ab490e154336
# ╟─ddc9648c-0704-4615-aeaf-2673d5f903b2
# ╟─88f185e1-307d-497a-bb71-4d67080c65b6
# ╟─0f95ebb8-6db9-40b5-ab16-4759eab46df7
# ╠═28256565-ce91-468c-a891-5548f02acc3b
# ╟─b929203f-3418-4ef8-a33c-190e6e8e317f
# ╠═5919f304-1b58-44a8-b589-750251897375
# ╟─8b28a0c4-82c0-4526-87b8-dd792278625d
# ╠═5884513e-7633-468f-8002-7e6a48a0c88a
# ╟─0a5fff1f-893c-4817-9e9a-31f353e88466
# ╠═70429b94-3802-462a-9e15-1da1c2410c03
# ╠═a1ad0689-abe5-4f7c-8f50-e0685b3aaaf9
# ╟─99f0a709-8a6c-43f7-b651-12aa770e8c61
# ╠═5ec428fb-fd9b-4a07-9c06-e649708cdb83
# ╠═e81d199d-3888-4178-86e4-36760457f304
# ╠═f3f65c4e-80bb-44cc-a0fa-12efca19f50d
# ╠═6bd5d895-e2ea-4d2d-870c-e1556facee6e
# ╟─9336e2e7-f75b-4313-94fb-fdf7117796c9
# ╠═86da409a-1451-4093-bf72-67781e3679ac
# ╟─731e4eb8-b90e-425e-9bca-028ee58c8dd1
# ╠═a66dcc0b-ce43-4eef-8b4b-c9d425c194bf
# ╠═4ed4b8eb-63d6-41d4-963d-32d766350982
# ╠═9f891a05-64e7-495f-9d75-4a4de2fd2607
# ╠═b165ee67-c0e0-49b5-834a-20150b94af75
# ╟─11762102-f44a-4bae-b618-4d110e532522
# ╠═0d25abea-e440-4757-9565-8a2e77685ded
# ╠═29554cd2-7ae0-4147-9303-d4117f887e8b
# ╟─b2f090c1-5a77-4132-8383-85c280f5915b
# ╟─7ea552f2-0a46-4e1a-a0e4-46998f77c47b
# ╠═953090eb-dc96-4e17-b9e8-23f72f5c77b3
# ╟─e6573104-1a1e-42e4-bf76-65d71d2a418c
# ╟─ff45ee57-8a5e-4520-8b10-2238fff67076
# ╠═e529f320-de94-49ae-b2e4-61233193fb89
# ╟─9c770f5d-1447-4bd1-9a5c-8ac486cf394c
# ╟─2aa05c08-ae3a-4fa9-8d12-729f918130ab
# ╟─5cadc8cd-6821-4e8f-9976-84a729029675
# ╠═3732453b-cf67-4087-8bca-f048b0ed81a2
# ╟─acc8a1ab-2da1-4112-803a-13b957a44206
# ╠═13e28629-e8da-4f8f-beb9-13bdb2d47df5
# ╟─79307eba-ac13-4abe-9dca-2312d322e931
# ╠═842e570e-9b8b-45f7-b22c-4811512835e2
# ╟─b96d0fa2-bc1b-4c9d-848a-a58ffd44f448
# ╠═914b6207-7388-4d65-9a79-5363f3bf45b5
# ╟─b6af4611-2b06-42e6-91d3-4eec372eeb1e
# ╟─37aafa42-5ee3-420d-bb2e-8980c3288272
# ╠═1ca1f4b3-24a2-4d91-bf89-9eb3802d24b5
# ╟─4f51e99c-a822-4667-a485-75f6b48f6287
# ╟─98a230ec-25bf-4e77-aab5-20bc6b69d32b
# ╠═d268b813-0ee8-4d9c-abe8-b565c38ead8e
# ╟─7a094d01-7906-4c8f-8a26-627f1558f0e6
# ╠═eabeac06-3adc-4384-bee4-5a11d8b9d422
# ╟─86519046-8e69-4c66-812d-d9bbb074f7cc
# ╠═2872d214-0db8-48b9-9280-d2554495e108
# ╟─2217bab6-00a4-4fb5-9950-5ed9f717ad38
# ╠═7e5439ae-c9f4-43c3-af0a-adb1084b549b
# ╠═0420b357-850c-4d92-809b-c22d6f091010
# ╟─8d10edcc-f6d7-459f-8464-204352fb56ab
# ╠═914717da-e086-442c-bbf7-b7548125b038
# ╠═51b1d76e-9ddf-4524-b560-e69900bee55f
# ╟─da511c9c-391a-4258-96f9-00ee38f95a92
# ╠═844b08df-6e28-4476-b1e7-2108752d5c27
# ╟─59095d92-89d9-453f-a3ef-c471126c667f
# ╟─fd14bf64-dce1-46db-8e2d-d95b8f467406
# ╠═8dd9436b-911e-4573-a9ed-feafe24b7061
# ╟─ae571d48-b21a-4002-9f5c-274cbf142c7a
# ╠═570ca407-96a9-4e21-923f-971bebfc1258
# ╟─8fea754e-6061-4943-b1fc-9fd645b75875
# ╟─27d6a970-5212-41fa-8c5f-45910c0aad65
# ╠═cefe71ef-d2fa-4258-9e67-250d7f6c0959
# ╟─795c01ba-60b9-4af9-b1e9-bf0de27f590c
# ╠═465439e9-ea8f-4fea-974f-81cd0579c38c
# ╟─cf31336f-f05a-459e-9082-dfcba1006718
# ╟─dde68756-7ccb-4fb8-aad5-93bfdb786a93
# ╟─eec721fb-8d4d-49ac-a331-daf919f72f23
# ╟─6ad68ec4-e762-4f0d-b959-d40e556d8a06
# ╟─0afc7172-c3d5-4731-93ec-40a97476dab6
# ╟─8beb7ffd-4627-4350-8117-356dae98884d
# ╟─f4760cb3-c270-4dfc-b589-d90cfb1a7031
# ╠═5a9d2343-d366-4504-87ef-ce4e1de959fb
