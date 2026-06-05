# vpnfast — sing-box rule-sets

Готовые [sing-box](https://sing-box.sagernet.org/) rule-set'ы для роутинга трафика через прокси (HomeProxy / OpenWrt).

## Vultr (AS20473)

Все анонсируемые подсети Vultr/Choopa (`AS20473`). Удобно, когда нужно завернуть
трафик к серверам Vultr через VPN-ноду («хоп»), например чтобы достучаться до
своего VPS, чей прямой выход режется.

| Файл | Формат | Назначение |
|------|--------|------------|
| [`vultr.json`](./vultr.json) | source | человекочитаемый исходник rule-set |
| [`vultr.srs`](./vultr.srs)   | binary | скомпилированный rule-set для sing-box |

### Подключение в HomeProxy (remote ruleset)

```
url:    https://raw.githubusercontent.com/farwydi/vultr-rulesets/main/vultr.srs
format: binary
```

Список префиксов обновляется автоматически (GitHub Action, раз в сутки) из
[RIPEstat](https://stat.ripe.net/) по `AS20473`.

## Ручная пересборка

```bash
bash scripts/generate-vultr.sh           # -> vultr.json
sing-box rule-set compile --output vultr.srs vultr.json
```
