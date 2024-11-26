//import express from 'express'
const express = require('express')

const app = express()

const hostname = 'localhost'
const port = 3000

app.get('/', function (req, res) {
    res.send('Hello World!')
})

app.listen(port, hostname, () => {
    console.log(`Server running at http://${hostname}:${port}/`)
})