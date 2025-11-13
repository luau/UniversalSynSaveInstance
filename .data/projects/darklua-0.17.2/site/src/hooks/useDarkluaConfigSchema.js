import * as React from "react"

import * as Joi from "joi"

import { DarkluaContext } from "../components/darklua-provider"

const createConfigSchema = darklua => {
  const ruleNames = darklua.get_all_rule_names()
  const ruleSchema = Joi.alternatives().try(
    Joi.string().valid(...ruleNames),
    Joi.object({
      rule: Joi.string().valid(...ruleNames),
    }).unknown(),
  )

  return Joi.object({
    rules: Joi.array().items(ruleSchema),
  })
}

const useDarkluaConfigSchema = () => {
  const darklua = React.useContext(DarkluaContext)

  const [configSchema, setConfigSchema] = React.useState(() =>
    Joi.object({
      rules: Joi.array().items(
        Joi.alternatives().try(
          Joi.string(),
          Joi.object({
            rule: Joi.string(),
          }).unknown(),
        ),
      ),
    }),
  )

  React.useEffect(() => {
    if (darklua) {
      setConfigSchema(createConfigSchema(darklua))
    }
  }, [darklua])

  return configSchema
}

export default useDarkluaConfigSchema
