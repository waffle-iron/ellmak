import { trace } from '../utils/logger'

const pad = (pad, str, padLeft) => {
  if (typeof str === 'undefined') {
    return pad
  } else if (padLeft) {
    return (pad + str).slice(-pad.length)
  } else {
    return (str + pad).substring(0, pad.length)
  }
}

const toPercent = (num, dem) => {
  return ((parseFloat(num) / parseFloat(dem)) * 100).toFixed(2)
}

const bytesToString = (bytes) => {
  var currval = parseFloat(bytes)

  for (var i = 0; currval > 1024; i++) {
    currval = currval / 1024
  }

  const cvs = currval.toFixed(2)
  var res
  switch (i) {
    case 0:
      res = cvs + ' B'
      break
    case 1:
      res = cvs + ' KiB'
      break
    case 2:
      res = cvs + ' MiB'
      break
    case 3:
      res = cvs + ' GiB'
      break
    case 4:
      res = cvs + ' TiB'
      break
    case 5:
      res = cvs + ' PiB'
      break
    case 6:
      res = cvs + ' EiB'
      break
    case 7:
      res = cvs + ' ZiB'
      break
    case 8:
      res = cvs + ' YiB'
      break
    default:
      res = cvs + ' ?iB'
      break
  }

  return res
}

const spitStats = (stats) => {
  const spaces = '      '
  const id = stats['indexedDeltas']()
  const io = stats['indexedObjects']()
  // const lo = stats['localObjects']()
  const rb = stats['receivedBytes']()
  const ro = stats['receivedObjects']()
  const td = stats['totalDeltas']()
  const to = stats['totalObjects']()
  const rop = pad(spaces, toPercent(ro, to), true)
  const iop = pad(spaces, toPercent(io, to), true)
  const btos = bytesToString(rb)

  var idpv = toPercent(id, td)
  if (isNaN(idpv)) {
    idpv = 0
  }
  const idp = pad(spaces, idpv, true)

  return trace(`Received: ${rop}% | Indexed: ${iop}% | Deltas: ${idp}% | Received: ${btos}`)
}

export default spitStats
