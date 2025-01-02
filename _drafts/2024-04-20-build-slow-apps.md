---
layout: post
title: Build Slow Apps
published: false
---

I love web development. I always wanted to create a site thats super useful and
does one thing well. In my 15 odd years of programming & running multiple
companies, I have tried many different frameworks to build interfaces both in
mobile and web but I have never felt it made me happy & always felt something
was wrong.

I loved the simplicity of jQuery, unidirectional data flow of React, ease of
Alpine & the ability to structure applications as components. But I defintely
think the current tools are overly complicated and kills the excitement to just
try an idea and deploy. The sheer number of config files in a typical frontend
application is not just dirty, its just noise for nearly no value.

I know, its useful. But not for 99% of websites out there. Think about it, most
of the applications we envision doesn't need a bundler to do transpile,
treeshake or convert from a zillion intermediate languages to the simple markup
of web.

Recently I was wondering why I don't mirror my behaviour of building numerous
commands/aliases/functions in my machine to web or mobile! Mobile specifically
is with me all the time, but I have just one app in it that I made as opposed to
hundreds in my machine for easing my daily chores.

I think I know the answer: its fun, easy and frictionless to create a script and
put in the `PATH` of the machine to save a few minutes daily. To warrant an app
in mobile, you need to save not just hours, but days! Its that tedious,
complicated and outright painful to build something for mobile. Web is still not
this bad but effectively due to the bloated frameworks the free platform is
getting unnecessarily obtuse to approach.

> Enough! I want to go back to the good old days!

I want to build simple web apps, or PWAs as they are known by the cool kids
these days & I don't want to build it with boat load of `node_modules` or crazy
workflows. I want to start with two or three plain files and move them to a
server to deploy. Nothing more.

But what about performance? what about bundle size? what about lighthouse score?
what about time-to-first-paint? The answer is quite simple: I couldn't care
less!

> My site will only load in 1.2 seconds, please feel free to avoid it!

My site will have some unwanted code! Because I am not going to tree shake them.
Lighthouse will give me less than 90%, and I am fine with that. And Google may
rank me down - be my guest! I just don't care.

These apps are for me and for anyone who doesn't mind an additional 500ms load
time. So, please excuse me. I build slow apps.


So, here is my manifesto:

- Build your ideas. Its super easy, don't let the corporates fool you into
complexity.
- Learn the basics well. Thats all you need for most of your ideas.

While trying my hand at this, I have been trying out various ideas using basic
HTML/CSS/JS. Frankly, JS is pretty good now, but I truthfully missed modern
niceties of reactivity and components. So, I ventured out to find potential
canditates to improve the experience with minimal complexity. This blog is my
learning across an year trying to build using vanila JS, Alpine, jQuery and
finally my favorite: Petite Vue!

I have to say, I am so enamoured by Petite Vue that I think I will be using it
forever.
