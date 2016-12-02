import { info } from '../utils/logger'

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
  const kb = (parseFloat(rb) / 1024).toFixed(2)

  var idpv = toPercent(id, td)
  if (isNaN(idpv)) {
    idpv = 0
  }
  const idp = pad(spaces, idpv, true)

  return info(`Received: ${rop}% | Indexed: ${iop}% | Deltas: ${idp}% | Received: ${kb} KB`)
}

export default spitStats
