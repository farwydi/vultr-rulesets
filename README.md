# vultr-rulesets — sing-box rule-set для подсетей Vultr

[![Update Vultr ruleset](https://github.com/farwydi/vultr-rulesets/actions/workflows/update-vultr.yml/badge.svg)](https://github.com/farwydi/vultr-rulesets/actions/workflows/update-vultr.yml)

Готовый [sing-box](https://sing-box.sagernet.org/) rule-set со **всеми анонсируемыми
подсетями Vultr/Choopa (`AS20473`)**. Удобно, когда нужно завернуть трафик к серверам
Vultr через VPN-ноду («хоп») — например, чтобы достучаться до своего VPS, чей прямой
выход режется.

Список префиксов обновляется автоматически (GitHub Action, раз в сутки) из
[RIPEstat](https://stat.ripe.net/) по `AS20473`.

| Файл | Формат | Назначение |
|------|--------|------------|
| [`vultr.json`](./vultr.json) | source | человекочитаемый исходник rule-set |
| [`vultr.srs`](./vultr.srs)   | binary | скомпилированный rule-set для sing-box |

## Подключение в HomeProxy (OpenWrt)

1. **Rule Set** → добавить *remote* rule-set:

   ```
   url:    https://raw.githubusercontent.com/farwydi/vultr-rulesets/main/vultr.srs
   format: binary
   ```

2. **Routing Rule** → новое правило: `rule_set = vultr`, `outbound = proxy`.

   Без правила сам по себе rule-set ничего не делает — он лишь набор подсетей;
   именно правило отправляет совпавший трафик в нужный outbound.

Эквивалент в `uci` (HomeProxy):

```sh
uci set homeproxy.vultr=ruleset
uci set homeproxy.vultr.label='vultr'
uci set homeproxy.vultr.enabled='1'
uci set homeproxy.vultr.type='remote'
uci set homeproxy.vultr.format='binary'
uci set homeproxy.vultr.url='https://raw.githubusercontent.com/farwydi/vultr-rulesets/main/vultr.srs'
uci set homeproxy.vultr.outbound='proxy'

uci set homeproxy.vultr_list=routing_rule
uci set homeproxy.vultr_list.label='vultr'
uci set homeproxy.vultr_list.enabled='1'
uci set homeproxy.vultr_list.mode='default'
uci set homeproxy.vultr_list.rule_set='vultr'
uci set homeproxy.vultr_list.action='route'
uci set homeproxy.vultr_list.outbound='proxy'

uci commit homeproxy && /etc/init.d/homeproxy reload
```

## Прямое использование в sing-box

```json
{
  "route": {
    "rules": [
      { "rule_set": "vultr", "outbound": "proxy" }
    ],
    "rule_set": [
      {
        "type": "remote",
        "tag": "vultr",
        "format": "binary",
        "url": "https://raw.githubusercontent.com/farwydi/vultr-rulesets/main/vultr.srs",
        "download_detour": "proxy"
      }
    ]
  }
}
```

## Ручная пересборка

```bash
bash scripts/generate-vultr.sh                       # -> vultr.json
sing-box rule-set compile --output vultr.srs vultr.json
```

## Лицензия / источник данных

Данные о префиксах — [RIPEstat Data API](https://stat.ripe.net/docs/data_api)
(`announced-prefixes` для `AS20473`).
