
import SwiftUI

struct HelpView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Uitleg & gebruiksfuncties")
                    .font(.title2)
                   .bold()

                Group {
                   
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.footnote)
                            .foregroundColor(.blue)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Complicaties:")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("""
                            Deze menuoptie laat je zoeken in de complicatie~locatie-code zoals gebruikt in LCH. Met de zoekfunctie (zie onder) maak je een filter op de totaal lijst. Met zorgvuldig gekozen woordsegmenten van complicatie en locatie kun je snel tot een klein aantal opties komen. Met een klik op een complicatie kom je in een scherm met details. Zie onder voor verder opties. 
                            """)
                            .font(.subheadline)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "number.square")
                            .font(.footnote)
                            .foregroundColor(.green)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Codes:")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("Deze menuoptie laat je zoeken in een van 4 tripletten waaruit de complicatie~locatie-code bestaat: Hoofdgroepen (GRP), Soorten (SRT), Specificaties (SPC) en Locaties (LOC). Ook dit zoekveld werkt als een filter.")
                            .font(.subheadline)
                        }
                    }
                    
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "circle.grid.cross.fill")
                            .font(.footnote)
                            .foregroundColor(.orange)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Structuur:")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("Deze menuoptie laat je zoeken in óf de complicatiecode (los van locatie: SRTSPC), óf de locatiecode (los van complicatie: LOC). Ook dit zoekveld werkt als een filter.")
                            .font(.subheadline)
                        }
                    }
                    
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "square.grid.3x3.fill")
                            .font(.footnote)
                            .foregroundColor(.pink)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Matrix:")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("Deze menuoptie toont per gekozen groep de matrix van complicaties versus locaties. Een groen bolletje staat voor een actieve complicatie~locatie; een groene cirkel staat voor een inactieve complicatie-locatie en een grijze stip staat voor een niet bestaance complicatie-locatie. Scroll zo nodig.")
                            .font(.subheadline)
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "paperplane.circle")
                            .font(.footnote)
                            .foregroundColor(.purple)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Feedback:")
                                .font(.body)
                                .foregroundColor(.black)
                            Text("Deze menuoptie spreekt voor zich. Je kunt in het feedback formulier aangeven wat de categorie is van je feedback: UX staat voor User Experience, (hieronder valt alles over de werking van de app). Inhoud moet gebruikt worden voor inhoudelijke feedback over de complicaties. Ook kan aangegeven worden aan welk scherm de feedback refereert. \nFeedback kan ook contextueel gegeven worden (zie onder). Dat zorgt voor een automatische referentie naar oorsprong van de feedback (code en scherm) en heeft daarom de voorkeur. Een afzender e-mail is niet nodig, maar voor goed overleg uiteraard wel wenselijk.")
                            .font(.subheadline)
                        }
                    }
                    HStack(alignment: .top, spacing: 12) {
                        Text("🔍")
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Zoekfunctie:")
                                .font(.body)
                                .bold()
                            Text("Type termen in het zoekveld om complicaties en codes te filteren (per karakter wordt het filter bijgewerkt).  Meerdere zoektermen (gescheiden door spaties) kunnen worden gecombineerd (EN-filter). Indien een term uit drie hoofdletters bestaat wordt in de code (GRP.SRT.SPC.LOC)gezocht.")
                                .font(.subheadline)
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("🟢").font(.footnote)
                        VStack(alignment: .leading, spacing: 4) {
                               Text("Gematchte termen:")
                                   .font(.body)
                                   .foregroundColor(.green)
                               Text("Gematchte (onderdelen van) woorden kleuren groen.")
                                   .font(.subheadline)
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("🟥").font(.footnote)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Inactieve complicaties:")
                                .font(.body)
                                .foregroundColor(.red)
                                .strikethrough(true, color: .red)
                            Text("In 1e instantie worden in de complicatie~locatie-lijst alleen actieve complicaties getoond. Als de slider (boven het zoekvak) uitgezet wordt, toont het filter ook inactieve complicaties (rood en doorgestreept).")
                                .font(.subheadline)
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Text("🟠").font(.footnote)
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Uitsluitingen:")
                                .font(.body)
                                .foregroundColor(.orange)

                            Text("Via links vegen kun je in de complicatie~locatie-lijst een complicatie tijdelijk van het huidige filter uitsluiten. Dit is handig om het overzicht te krijgen van alleen relevante opties. \nBoven de lijst wordt het aantal uitsluitingen getoond in oranje.")
                                .font(.subheadline)
                            
                            HStack(alignment: .firstTextBaseline, spacing: 4) {
                                Image(systemName: "xmark.circle")
                                    .font(.caption)
                                    .foregroundColor(.orange)
                                Text("Je kunt alle uitsluitingen weer wissen door op dit icoon te klikken, maar een uitsluiting verdwijnt ook bij een nieuwe zoekactie.")
                                    .font(.system(size: 12.5))

                            }
                            
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "paperplane.circle")
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Via dit icoon kun je op 3 plaatsen contextuele feedback geven:")
                                .font(.subheadline)
                            Text("1.[Details]: gekozen complicatie (rechtsboven) \n2.[Complicaties]: bij 0 zoekresultaten \n3.[Codes]: d.m.v. links swipen")
                                .font(.system(size: 12.5))
                        }
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "info.circle")
                            .foregroundColor(.blue)
                        Text("Via dit icoon (linksboven) wordt een overzicht van de geladen bestandsinformatie getoond.")
                            .font(.subheadline)
                    }
                    
        

                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "questionmark.circle")
                            .foregroundColor(.blue)
                        Text("Via dit icoon (rechtsboven) wordt dit cherm getoond.")
                            .font(.subheadline)
                    }
                }
                
            }
            .padding()
        }
        .navigationTitle("Info")
    }
}
