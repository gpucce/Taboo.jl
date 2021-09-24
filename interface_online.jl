### A Pluto.jl notebook ###
# v0.16.0

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ e021e510-161d-11ec-15a5-c3c536555e2f
begin
	using Pkg
	Pkg.activate(".")
	using JSON, Luxor, Colors, PlutoUI, EzXML, Markdown, Random, SMTPClient, Base64
	import Gumbo, HTTP, Cascadia
end

# ╔═╡ 6c69c513-1998-4520-9a46-ba8e8580429e
md"""
## Reset the game $(@bind do_reset_game CheckBox())
"""

# ╔═╡ 85cc9b1f-f294-4564-8b48-b6401d858e6d
begin
do_reset_game
md"""
### Choose a language/Scegli una lingua $(@bind language Select(["en", "it"].=>["English", "Italiano"]))
"""
end

# ╔═╡ 5ef6e834-e1ee-4abc-ab4d-35cc43c5fb67
if language == "en"
md"""
# Let's play *360° Taboo*
"""
else
md"""
# Giochiamo a *Taboo a 360°*
"""
end

# ╔═╡ d75cd685-7e1f-4cf3-84d4-d6d1f2ad0d0a
if language == "en"
md"""
### Type in the word to search $(@bind keyword TextField((30, 1)))
"""
else
md"""
### Scrivi la parola che vuoi cercare $(@bind keyword TextField((30, 1)))
"""
end

# ╔═╡ 97ab7332-93af-44e2-9ac2-19dade5c7f97
begin
	if language == "en" 
		md"""
		### Select the number of cards $(@bind n_cards_notebook NumberField(5:20, default=5))
		"""
	else
		md"""
		### Seleziona il numero di carte $(@bind n_cards_notebook NumberField(5:20, 		default=5))
		"""
	end
end

# ╔═╡ 09f548fa-ccc0-4575-86e4-4ae3ac3e6ea9
if language == "en"
md"""
### Check to start Playing $(@bind docompute CheckBox())
"""
else
md"""
### Clicca per iniziare a Giocare $(@bind docompute CheckBox())
"""
end

# ╔═╡ f0ac28e4-1332-4cf9-be4b-e5b7057497d8
if language == "en"
md"""
## Write here your email $(@bind receiver_address TextField()) and check this box $(@bind accept_send CheckBox()) to have a copy of the cards!!
"""
else
md"""
## Scrivi qua la tua email $(@bind receiver_address TextField()) e clicca questa casella $(@bind accept_send CheckBox()) per ricevere una copia delle tue carte!!
"""
end

# ╔═╡ 2e7745a4-1011-494f-9471-17360c198068
begin
	if accept_send
		opt = SendOptions(
  			isSSL = true,
  			username = "b4dsatbright@gmail.com",
  			passwd = ""
		)
		no_space_keyword = replace(keyword, " "=>"_")
		attachments = readdir("""$(no_space_keyword)_temporary""", join=true)
		
		url = "smtps://smtp.gmail.com:465"
		
		message = if language == "en"
			"Here are your cards!!"
		else
			"Ecco le tue carte!!"
		end
		
		subject = "B4DS@bright"

		to = ["<$(receiver_address)>"]
		cc = [""]
		bcc = [""]
		from = "<pucce92@gmail.com>"
		replyto = ""

		body = body = IOBuffer(
			"Date: Fri, 18 Oct 2013 21:44:29 +0100\r\n" *
			"From: You <$(receiver_address)>\r\n" *
			"To: $(receiver_address)\r\n" *
			"Subject: Julia Test\r\n" *
			"\r\n" *
			"Test Message\r\n"
		)
		url = "smtps://smtp.gmail.com:465"
		rcpt = ["<$(receiver_address)>"]
		from = "<pucce92@gmail.com>"
		
		body2 = get_body(to, from, subject, message; attachments)
		
		resp = send(url, rcpt, from, body2, opt)
	end
end;

# ╔═╡ f97d9287-54f6-4a47-9305-02ace869facb
begin
	function crawler(stringa; lang="en", n_words=10)
		wurl = "https://$(lang).wikipedia.org/w/index.php?search="
		r = HTTP.get(join([wurl, replace(stringa, " "=>"+")]))
		h = string(parsehtml(String(r.body)))
		if occursin(Regex("<title>.*?the free encyclopedia.*?</title>", "i"), h)
			error("Your query is ambiguous")
		end
		no_space_stringa = match(
			Regex("<title>(.*?) - Wikipedia</title>"),
			h
		).captures[1]
		
		global_match = match(
			Regex("<p>.*?<b>$(no_space_stringa).*?<div", "si"), 
			h
		).match
		
		m = map(eachmatch(Regex("<a href=.*?title=\"(.*?)\">"), global_match)) do i 
			strip(i.captures[1])
		end
		
		m = filter(m) do w
			!any([
					occursin("Help", w),
					occursin("Wikipedia", w),
					occursin(r"^\d+$", w),
					occursin("Aiuto", w),
					]
			)
		end
		
		string.(m)[1:min(length(m), n_words)]
	end
	
	function full_crawler(stringa; lang="en", n_keywords=5, n_words=5)
		crawled = crawler(stringa, lang=lang, n_words=n_keywords)
		out = Dict()
		for crawl in crawled
			try
				push!(out, crawl=>crawler(crawl, lang=lang, n_words=n_words))
			catch
			end
		end
		return out
	end	
end;

# ╔═╡ d3215f60-87f7-4e6b-b454-938e02648a36
function process_keywords(stringa)
	uppercasefirst(replace(stringa, " "=>"_"))
end;

# ╔═╡ 2a7c89f2-b08a-4393-b030-472d74b3ad2d
begin
	if docompute
		cards2be = try
			oldcards2be = full_crawler(process_keywords(keyword), lang=language, n_keywords = n_cards_notebook)
			local cards2be = Dict()
			for i in keys(oldcards2be)
				cards2be[replace(i, "_"=>" ")] = replace.(oldcards2be[i], "_"=>" ")
			end
			cards2be
		catch
			if language == "en"
				md"""
				### Make a more accurate query than _$(keyword)_
				"""
			else
				md"""
				### Fai una ricerca piú accurata di _$(keyword)_
				"""
			end
		end
	end
end

# ╔═╡ 0c9271ba-9631-44cf-872e-052499951d3d
function draw_card(word, notwords, keyword, idx; color=colorant"red")
	card = Drawing(500, 500, joinpath(keyword, """$(replace(word, " "=>"_"))_$(idx).png"""))
	origin()
	sethue(color)
	squirclewidth = 200
	squircleheight = 240
	squircle(O, squirclewidth, squircleheight, rt=0.3, :fill)
	colorcomponents = [color.r, color.g, color.b]
	colorcomponents = map(colorcomponents) do c
		if c == colorcomponents[argmax(colorcomponents)] 
			c - min(0.7, c)
		else
			min(1, c + 0.6)
		end
	end
	sethue(RGB(colorcomponents...))
	p_up = O - (0, squircleheight * 2/3)
	p_down = O + (0, squircleheight * 1/4)
	squircle(p_up, squirclewidth * 5/6, squircleheight * 1/6, rt=0.3, :fill)
	squircle(p_down, squirclewidth * 5/6, squircleheight * 2/3, rt=0.3, :stroke)
	# sethue("black")
	fontsize(20)
	fontface("JuliaMono")
	sethue(color)
	text(word, p_up, halign=:center, valign=:middle)
	sethue(RGB(colorcomponents...))
	for (idx, notword) in enumerate(notwords) 
		text(
			notword, 
			p_down - (0, squircleheight * 4/7) + (0, 40 * idx), 
			halign=:center, 
			valign=:middle
		)
	end
	finish()
	card
end;

# ╔═╡ 8eb315cf-abf8-4f0b-9c4e-fdf07a7aecc1
mycolors = [collect(Colors.JULIA_LOGO_COLORS)[[1,3,4]]; colorant"springgreen"; RGB(0.94, 0.94, 0.3)];

# ╔═╡ bce30e71-7d09-4dcc-b78f-1d65273e2166
begin
	nospacekeyword = replace(keyword, " "=>"_") * "_temporary"
	pngs = if docompute
		try
			try
				mkdir(nospacekeyword)
			catch
				rm(nospacekeyword, recursive=true)
				mkdir(nospacekeyword)
			end
			pngs = []
			for (idx, card2be) in enumerate(cards2be)
				word, notwords = card2be
				card = draw_card(
					word, 
					notwords, 
					nospacekeyword, 
					idx, 
					color=mycolors[idx%5 + 1]
				)
				push!(pngs, card)
			end
			pngs
		catch
		end
	end
end;

# ╔═╡ 77643261-8114-44fc-b7c6-83bf83707f94
begin
	if docompute
	md"""
	### Scroll Cards $(@bind ncard NumberField(1:length(pngs)))
	"""
	end
end

# ╔═╡ c36a5f51-4078-4c47-8dda-49b7d659b226
if docompute
	try
		pngs[ncard]
	catch
	end
end

# ╔═╡ Cell order:
# ╟─5ef6e834-e1ee-4abc-ab4d-35cc43c5fb67
# ╟─85cc9b1f-f294-4564-8b48-b6401d858e6d
# ╟─d75cd685-7e1f-4cf3-84d4-d6d1f2ad0d0a
# ╟─97ab7332-93af-44e2-9ac2-19dade5c7f97
# ╟─09f548fa-ccc0-4575-86e4-4ae3ac3e6ea9
# ╟─2a7c89f2-b08a-4393-b030-472d74b3ad2d
# ╟─bce30e71-7d09-4dcc-b78f-1d65273e2166
# ╟─77643261-8114-44fc-b7c6-83bf83707f94
# ╟─c36a5f51-4078-4c47-8dda-49b7d659b226
# ╟─f0ac28e4-1332-4cf9-be4b-e5b7057497d8
# ╟─6c69c513-1998-4520-9a46-ba8e8580429e
# ╟─e021e510-161d-11ec-15a5-c3c536555e2f
# ╟─2e7745a4-1011-494f-9471-17360c198068
# ╟─f97d9287-54f6-4a47-9305-02ace869facb
# ╟─d3215f60-87f7-4e6b-b454-938e02648a36
# ╟─0c9271ba-9631-44cf-872e-052499951d3d
# ╟─8eb315cf-abf8-4f0b-9c4e-fdf07a7aecc1
