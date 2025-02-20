const IpMiddleware = (task) => (req, res, next) => {
  const ip = req.headers['x-forwarded-for'] || req.connection.remoteAddress
  //eslint-disable-next-line
  console.log(`\x1b[0mThe IP address : \x1b[31m'${ip}'\x1b[0m has requested : \x1b[32m${task}\x1b[0m`)
  next()
}

export default IpMiddleware