# GatherIndicatorPlus
WoW Forever-first lightweight gathering minimap enhancement. **Version 0.1.0 is a capability diagnostic, not a functional icon-replacement addon.**

## Intended behavior
Replace generic gathering tracking dots with resource icons where Blizzard exposes reliable node identity and location; show profession difficulty using native Blizzard colors: gray minus, green single chevron, yellow double chevron, orange triple chevron, and red minus for insufficient skill. Never guess node identity or location.

## Diagnostic test
Install the GatherIndicatorPlus folder in Interface/AddOns. Enable Find Herbs or Find Minerals and stand near visible yellow dots. Run `/gip report` and `/gip scan`; screenshot chat output. Repeat scan with tracking off. Report client build and any Lua errors.

## Commands
`/gip`, `/gip report`, `/gip scan`, `/gip debug`, `/gip on`, `/gip off`, `/gip reset`.

## Development
StormCore standards: https://github.com/DustinChecketts/stormcore
This is standalone and has no runtime StormCore dependency. No release or tested compatibility is claimed yet.
