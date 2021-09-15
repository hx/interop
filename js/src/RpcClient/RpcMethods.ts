import { NO_CONTENT } from '../ContentType'

export interface SignaturesBase {
  [k: string]: [unknown, unknown]
}

export type Guards<Signatures extends SignaturesBase> = {
  [K in keyof Signatures]: (obj: unknown) => obj is Signatures[K][1]
}

export type RpcMethods<Signatures extends SignaturesBase> = {
  [K in keyof Signatures]: (content: Signatures[K][0]) => Promise<Signatures[K][1]>
}

export function createRpcMethods<Signatures extends SignaturesBase>(
  queryDelegate: (name: string, content: unknown) => Promise<unknown>,
  guards?: Partial<Guards<Signatures>>
): RpcMethods<Signatures> {
  const methods: Record<string, () => unknown> = {}

  return new Proxy({} as RpcMethods<Signatures>, {
    get(target, name) {
      if (typeof name !== 'string') {
        return
      }

      const guard = guards?.[name]

      return methods[name] ||= async (content: unknown = NO_CONTENT) => {
        const result = await queryDelegate(name, content)
        if (guard && !guard(result)) {
          throw new Error(`unexpected response for call "${name}"`)
        }
        return result
      }
    }
  })
}
