---
layout: post
title: Petite Vue Is Just Awesome!
published: true
---

Petite Vue is an attempt by the creator of Vue to create a simple, light weight
solution to bring some interactivity to pages without much complexity. It boast
of just 6KB bundle and it has similar ideas from Vue.

This is the prima facie idea you get while reading the README. But its far from
the truth, I really don't know why the framework isn't given a better
documentation. It can probably do 95% of everything a modern framework like
React can do with 95% less things to learn!

The whole framework is less than 1000 lines of code and its super well done. You
get reactivity and components out of the box. But thats not the greatest draw:
the components are pure JS files! Yes, absolutely no other dependencies are
needed!

Think about the framework to provide only reactivity and an interesting `way` of
splitting your app into pure JS files/components. Your app will work for
decades, with no `node_modules` coming to eat it off in months.

## Unofficial Petite Vue Doc

As mentioned Petite Vue gives pure JS components and reactivity. Lets see how?
Your typical `app.js` will look like this:


``` js
import {
  createApp,
  reactive,
} from "https://unpkg.com/petite-vue@0.2.2/dist/petite-vue.es.js"

import { Todos } from "./components/Todos.js"

const store = reactive({
  todos: [
    { label: "Buy Milk", done: { value: false }, key: 0 },
    { label: "Exercise", done: { value: false }, key: 1 },
  ],
  toggle(key) {
    const index = this.todos.findIndex(item => item.key === key)
    this.todos[index].done.value = !this.todos[index].done.value
  },
})

createApp({
  store,
  Todos,
}).mount()

```
