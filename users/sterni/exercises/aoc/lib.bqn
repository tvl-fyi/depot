IsAsciiNum ⇐ ('0'⊸≤∧≤⟜'9')

ReadInt ⇐ {(𝕨⊸×+⊣)´∘⌽-⟜'0'𝕩} # stolen from leah2
ReadDec ⇐ 10⊸ReadInt

SplitOn ⇐ ((⊢ (-1˙)⍟⊣¨ +`∘(1⊸»<⊢))∘(≡¨)⊔⊢)

_fix ⇐ {𝕩 𝕊∘⊢⍟≢ 𝔽 𝕩}
