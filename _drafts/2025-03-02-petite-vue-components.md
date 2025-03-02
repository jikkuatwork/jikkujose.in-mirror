---
layout: post
title: "Exploring Petite Vue: A Lightweight Framework"
excerpt: "A guide to Petite Vue for enhancing server-rendered HTML"

---

Petite Vue is a standalone, lightweight (~6kb) framework distinct
from Vue.js, tailored for progressively enhancing server-rendered
HTML. Unlike Vue.js, which targets full single-page applications,
Petite Vue adds interactivity to existing pages without a build
step. This post explores its concepts, setup, components, and best
practices with examples. You can copy-paste this into an LLM for
context and ask it to generate a Petite Vue component.

## What is Petite Vue?

Petite Vue isn’t a trimmed-down Vue.js—it’s a separate framework
with a unique goal. It enhances static HTML using a reactivity
system inspired by Vue, operating directly in the DOM without a
virtual DOM.

### Key Features

- **Lightweight**: ~6kb, keeping resource usage low.
- **No Build Step**: Use via CDN or ES modules—no tooling needed.
- **Familiar Syntax**: Uses `{{ }}`, `v-bind`, `v-on`, etc.
- **DOM-Based**: Mutates elements directly, no virtual DOM.
- **Progressive**: Enhances HTML without full control.
- **Reactivity**: Offers `reactive` for state management.

### How It Differs from Vue.js

Petite Vue and Vue.js differ fundamentally:

- **Separate Frameworks**: Built for enhancement, not SPAs.
- **No Virtual DOM**: Direct DOM edits vs. Vue’s abstraction.
- **Simple Components**: Functions, not full Vue definitions.
- **Limited Reactivity**: No `ref` or `computed`, but has `reactive`.
- **Lifecycle Hooks**: Only `@vue:mounted` and `@vue:unmounted`.

## Setting Up Petite Vue

Petite Vue integrates via CDN or ES modules. Here’s a setup with
Tailwind CSS (via `twind`) and an `importmap` for dependencies.

### ES Module Setup

```html
<script type="module">
  import { createApp } from 'https://unpkg.com/petite-vue@0.4.1/dist/petite-vue.es.js'
  import Loan from './pv/Loan.js'
  createApp({ Loan }).mount('#app')
</script>
<div id="app" v-scope="Loan()"></div>
```

- **Explanation**: Mounts `Loan` to `#app` with `v-scope`.

### Assumptions

- **Tailwind CSS**: Via `twind` for styling.
- **Importmap**: Manages ES modules like `animejs`.

## Building Components

Components are functions returning objects with data, methods,
and `$template`. Below are tenets and examples.

### Tenets for Crafting Components

These 15 principles ensure robust components:

1. **Export as Object**: Return an object for Petite Vue.
2. **Accept Props**: Use an object parameter for props.
3. **Include Variables**: Return all template-used items.
4. **Support State**: Use locals or `reactive` for logic.
5. **Use Tailwind**: Style with Tailwind CSS (v2.2.19).
6. **Format Templates**: Tag `$template` with `/* HTML */`.
7. **Default Props**: Provide fallbacks for props.
8. **External State**: Manage state outside when needed.
9. **Dynamic Classes**: Use `:class` with JS objects.
10. **Return Dynamics**: Include all dynamic values.
11. **Nest Components**: Embed child components in object.
12. **Nested Props**: Set defaults for nested objects.
13. **ESM Imports**: Import dependencies as ES modules.
14. **Iterate with `v-for`**: Use for collections.
15. **Avoid Refs**: No `ref`; use `$refs` sparingly.

### Example: Reference Component

```javascript
import _ from 'https://cdn.jsdelivr.net/npm/lodash@4.17.21/+esm'

const Clicker = (props = {}) => {
  const { clicker = () => console.log('click') } = props
  return {
    $template: /* HTML */ `
      <div class="rounded bg-yellow-300 p-2" @click="clicker">
        Clicker
      </div>
    `,
    clicker
  }
}

const Reference = (props = {}) => {
  const { handleClick = () => console.log('click'), adjectives = ['Cool', 'Amazing'] } = props
  const colors = ['blue', 'yellow', 'green']
  let currentAdjective = _.sample(adjectives)
  let color = `bg-${_.sample(colors)}-300`

  const change = () => {
    currentAdjective = _.sample(adjectives)
    color = `bg-${_.sample(colors)}-300`
  }

  const $template = /* HTML */ `
    <div class="w-64 flex flex-col gap-2">
      <div class="p-2 rounded text-center" :class="color" @click="change">
        {{ 'Petite Vue is ' + currentAdjective }}
      </div>
      <div v-scope="Clicker({ clicker: handleClick })"></div>
    </div>
  `
  return { Clicker, $template, color, adjectives, currentAdjective, change, handleClick }
}

export default Reference
```

- **Usage**: `<div v-scope="Reference({ label: 'Hello' })"></div>`.

### Managing State with `reactive`

Use `reactive` for automatic DOM updates. Here’s a Tic-Tac-Toe:

```javascript
import { reactive } from 'https://unpkg.com/petite-vue@0.4.1/dist/petite-vue.es.js'

const TicTacToe = () => {
  const state = reactive({
    board: ["", "", "", "", "", "", "", "", ""],
    currentPlayer: "X",
    gameOver: false,
    status: "Player X's turn"
  })

  const play = (index) => {
    if (state.board[index] === "" && !state.gameOver) {
      state.board[index] = state.currentPlayer
      state.currentPlayer = state.currentPlayer === "X" ? "O" : "X"
      state.status = `Player ${state.currentPlayer}'s turn`
    }
  }

  const $template = /* HTML */ `
    <div class="p-4">
      <div>{{ state.status }}</div>
      <div class="grid grid-cols-3 gap-1">
        <button v-for="(cell, index) in state.board" @click="play(index)">
          {{ state.board[index] || ' ' }}
        </button>
      </div>
    </div>
  `
  return { $template, state, play }
}

export default TicTacToe
```

### Interactive Loan Calculator

A component to calculate EMI dynamically:

```javascript
const Loan = ({ initialLoanAmount = 25000000 } = {}) => {
  let loanAmount = initialLoanAmount

  const calculateEMI = (amount) => {
    const rate = 9 / 12 / 100
    const months = 16 * 12
    return (amount * rate * Math.pow(1 + rate, months)) / (Math.pow(1 + rate, months) - 1)
  }

  const $template = /* HTML */ `
    <div class="p-8 bg-white rounded-lg">
      <div class="text-xl">{{ calculateEMI(loanAmount).toFixed(2) }}</div>
      <input type="range" v-model="loanAmount" min="500000" max="100000000" step="100000" class="w-full">
    </div>
  `
  return { $template, loanAmount, calculateEMI }
}

export default Loan
```

### Dynamic Visuals with Vanta

Add visual effects with Vanta.js:

```javascript
import addResources from './utils/addResources.js'

const Vanta = (props = {}) => {
  const { fullScreen = false } = props

  const init = () => {
    addResources({ js: [
      'https://cdnjs.cloudflare.com/ajax/libs/three.js/r134/three.min.js',
      'https://cdn.jsdelivr.net/npm/vanta/dist/vanta.cells.min.js'
    ]}, () => {
      window.VANTA.CELLS({
        el: '#vanta',
        color: 0xd9c5f8,
        size: 1.0
      })
    })
  }

  const $template = /* HTML */ `
    <div @vue:mounted="init" class="flex flex-col">
      <div id="vanta" :class="{ 'w-full flex-grow': fullScreen, 'w-96 h-96': !fullScreen }"></div>
    </div>
  `
  return { $template, init }
}

export default Vanta
```

### Animated Dancers with Anime.js

Animate elements with Anime.js:

```javascript
import anime from 'https://cdn.jsdelivr.net/npm/animejs@3.2.2/+esm'

const AnimeDancers = ({ n = 15 } = {}) => {
  const init = () => {
    const city = document.querySelector('#city')
    for (let i = 0; i < n; i++) {
      const block = document.createElement('div')
      block.classList.add('dancer', 'w-8', 'bg-blue-500')
      block.innerText = i
      city.appendChild(block)
    }
    anime({
      targets: '.dancer',
      translateX: () => anime.random(-300, 300),
      duration: 800,
      loop: true
    })
  }

  const $template = /* HTML */ `
    <div @vue:mounted="init" class="flex flex-col">
      <div id="city" class="w-96 h-96"></div>
    </div>
  `
  return { $template, init }
}

export default AnimeDancers
```

### Numeric Text Animation

Animate digits with a slot-machine effect:

```javascript
import anime from 'https://cdn.jsdelivr.net/npm/animejs@3.2.2/+esm'

const VerticalNumbers = ({ after = 7 } = {}) => {
  const animate = (target) => {
    anime({
      targets: target.querySelector('.np-digits'),
      translateY: [-60, -((after + 2) * 20)],
      duration: 1000
    })
  }

  const $template = /* HTML */ `
    <div @vue:mounted="animate($el)" class="h-8 overflow-hidden">
      <div class="np-digits flex flex-col">
        <div>0</div><div>1</div><div>2</div><div>3</div><div>4</div>
        <div>5</div><div>6</div><div>7</div><div>8</div><div>9</div>
      </div>
    </div>
  `
  return { $template, animate }
}

const NumericText = ({ n = '45668' } = {}) => {
  const digits = n.split('').map(digit => ({ key: Math.random(), digit }))

  const $template = /* HTML */ `
    <div class="flex">
      <div v-for="item in digits" :key="item.key" v-scope="VerticalNumbers({ after: item.digit })"></div>
    </div>
  `
  return { $template, VerticalNumbers, digits }
}

export default NumericText
```

## Best Practices

Maximize Petite Vue’s potential with these tips:

- **Follow Tenets**: Stick to the 15 principles above.
- **Default Props**: Use fallbacks for robustness.
- **Optimize Templates**: Prefer `<template>` when possible.
- **Use Utilities**: Leverage `addResources` for scripts.
- **Reactivity**: Use `reactive` for state, or locals if not needed.

## Conclusion

Petite Vue offers a lightweight, component-driven approach to
enhance server-rendered HTML. With `reactive` for state (e.g.,
`TicTacToe`), visual effects (`Vanta`), tools (`Loan`), and
animations (`AnimeDancers`, `NumericText`), it’s versatile for
progressive enhancement. Copy-paste this post into an LLM to
generate custom Petite Vue components based on its examples and
tenets—no build process required.
