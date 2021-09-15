import { Marshaler } from './Marshaler'

export const jsonMarshaler: Marshaler = {
  async marshal(obj) {
    return new Blob([JSON.stringify(obj === undefined ? null : obj)])
  },

  async unmarshal(blob: Blob) {
    return JSON.parse(await blob.text())
  }
}

const blobParts = [
  Blob, ArrayBuffer,
  Int8Array, Uint8Array, Int16Array, Uint16Array, Int32Array, Uint32Array, Uint8ClampedArray, Float32Array, Float64Array,
]

const isBlobPart = (obj: unknown): obj is BlobPart =>
  typeof obj === 'string' ||
  (typeof obj === 'object' && obj !== null && blobParts.some(t => obj instanceof t))

export const nullMarshaler: Marshaler<Blob, BlobPart> = {
  async marshal(obj) {
    if (!isBlobPart(obj)) {
      obj = String(obj)
    }
    return new Blob([obj])
  },

  async unmarshal(blob) {
    return blob
  }
}
