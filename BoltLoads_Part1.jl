### A Pluto.jl notebook ###
# v0.19.2

using Markdown
using InteractiveUtils

# ╔═╡ 826a4961-0f3a-4306-8661-864672d6d65e
begin
	using Pkg

	Pkg.activate(Base.current_project())
	Pkg.instantiate()
	
	using Mechanical
	using Unitful
	
	using Unitful: mm, cm, m, inch, N, kN, lbf, MPa, psi
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
* **Part 1:** Determine the x, y cooridnates of each bolt within the bolt group.
"

# ╔═╡ 9073dd0d-5c1b-4182-911a-1929940ccee0
md"## 1. Calculate location of bolt coordinates
The first step is to calculate the coordinates of each bolt within the bolt group.

### Coordinates supplied from CAD Model or Drawing
Assuming you have access to a CAD model or drawing, you could probe the model directly to determine the x & y coordinates of the bolt pattern.

Consider the bolt pattern shown below:

"

# ╔═╡ 74993178-8941-4c5f-87aa-ecbdf57f1d83
begin
	p1_example = rectangle(x_dist = 300mm, y_dist = 300mm, Nx = 2, Ny = 2);
	plot_bolt_pattern(p1_example)
end

# ╔═╡ 4e81e565-0be2-455d-b74f-fe6b6fae43a0
md"""The x & y coordinates of the bolt pattern are shown below:

Bolt ID | x [mm] | y [mm]
:------------: | :-------------: | :-------------:
1 |-150 | 150
2 | -150 | -150
3 | 150 | 150
4 | 150 | -150

"""

# ╔═╡ ac412446-c094-43a4-9ccf-7ee5e8750d5c
md"We can manually enter the bolt pattern points as an x & y vector to enable further analysis; we enter the values for the x & y vectors from Bolt 1 to Bolt 4:"

# ╔═╡ d4e352b6-655b-4c34-838a-2697b877b7d8
x1 = [-150, -150, 150, 150]mm

# ╔═╡ 7769348e-b850-42ab-96c0-ed68e5fa22d1
y1 = [150, -150, 150, -150]mm

# ╔═╡ f6f37c90-54b3-4a81-ae6f-2a645af3636e
md"We can package the x & y vectors together to make further analysis with built-in functions relatively simple:"

# ╔═╡ 11413d0e-04db-41d6-b7d2-c7a6ca06cbe6
p1 = x1, y1

# ╔═╡ ae9402a0-3fd6-488a-80e3-fd44e0617cff
md"#### Exercise 🤔
**[Ex 1.1] Manually enter the values of `x2`, `y2` and `p2` for the bolt pattern as described in the table below:**

"

# ╔═╡ 85babb54-352a-48a9-b824-2a0aad1cc43a
begin
	x_1_1 = [-160, -110, 80, 188, 221]mm
	y_1_1 = [-80, 20, 101, 87, -35]mm
	p_1_1 = x_1_1, y_1_1
	plot_bolt_pattern(p_1_1)
end

# ╔═╡ 0cc8add8-92de-4359-8a15-47befeb57a72
md"""

Bolt ID | x [mm] | y [mm]
:------------: | :-------------: | :-------------:
1 |-160 | -80
2 | -110 | 20
3 | 80 | 101
4 | 188 | 87
5 | 221 | -35

"""

# ╔═╡ 85dfcd0c-a2b4-411a-a70e-40601e060923
x2 = "complete these details..."

# ╔═╡ d87ca29f-2ea4-4fa7-ab73-3758f9b16598
y2 = "complete these details..."

# ╔═╡ 7bb58885-fb0a-401c-b617-897bc8441cf6
p2 = "complete these details..."

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
# ╟─9073dd0d-5c1b-4182-911a-1929940ccee0
# ╟─74993178-8941-4c5f-87aa-ecbdf57f1d83
# ╟─4e81e565-0be2-455d-b74f-fe6b6fae43a0
# ╟─ac412446-c094-43a4-9ccf-7ee5e8750d5c
# ╠═d4e352b6-655b-4c34-838a-2697b877b7d8
# ╠═7769348e-b850-42ab-96c0-ed68e5fa22d1
# ╟─f6f37c90-54b3-4a81-ae6f-2a645af3636e
# ╠═11413d0e-04db-41d6-b7d2-c7a6ca06cbe6
# ╟─ae9402a0-3fd6-488a-80e3-fd44e0617cff
# ╟─85babb54-352a-48a9-b824-2a0aad1cc43a
# ╟─0cc8add8-92de-4359-8a15-47befeb57a72
# ╠═85dfcd0c-a2b4-411a-a70e-40601e060923
# ╠═d87ca29f-2ea4-4fa7-ab73-3758f9b16598
# ╠═7bb58885-fb0a-401c-b617-897bc8441cf6
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
# ╟─5a9d2343-d366-4504-87ef-ce4e1de959fb
