i ← •FLines •path∾"/input"
c ← ∾(↕26)⊸+¨"aA"
P ← {1+⊑c⊐⊑𝕩}
S ← (∊/⊣)
G ← ((⊣/(↕÷˜⟜≠))⊔⊢)

•Out "day03.1: "∾•Fmt +´(P S˝)¨2‿∘⊸⥊¨i
•Out "day03.2: "∾•Fmt +´3(P S´)¨∘G i
