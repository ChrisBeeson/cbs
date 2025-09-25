## Shareable Cells Catalog

Mark a cell shareable without moving it. Add to `applications/<app>/cells/<cell>/.cbs-spec/spec.md`:

```
**shareable**: true
```

Then generate the catalog:

```
cbs-agent/scripts/cbs-cell generate
```

Search:

```
cbs-agent/scripts/cbs-cell search --language dart --category ui
cbs-agent/scripts/cbs-cell search --id flow_ui
cbs-agent/scripts/cbs-cell search --subject cbs.flow_ui.render
```

Install into another app (copy):

```
cbs-agent/scripts/cbs-cell install flow_ui examples/flutter_flow_web
```

Outputs:
- `framework/docs/cell_catalog.md`
- `framework/docs/cell_catalog.json`

Notes:
- Cells must communicate over the bus only; catalog lists subjects to enforce design.
- No DB or migrations are required; pure file-based and git-friendly.


