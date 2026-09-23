// Suporte para pendurar o power bank Xiaomi Mi 50W 20000mAh (PB2050SZM) em um tripé.
//
// O power bank fica em pé dentro de um "berço" aberto em cima (portas para cima)
// e o berço prende no tripé de uma destas formas (escolha em `fixacao`):
//   "clip"   - abraçadeira de encaixe (snap) para tubo redondo: coluna central do tripé.
//   "argola" - uma argola (poste + olhal) para prender um MOSQUETÃO DE VERDADE (o de
//              chaveiro/alpinismo), não impresso. O poste sobe atrás do berço até
//              passar da altura total do power bank: a argola fica acima da bateria
//              inteira, então tudo pendura abaixo do ponto onde o mosquetão prende no
//              tripé (em vez de ficar torto/apoiado de lado).
//   "nenhum" - só o berço, com rasgos para passar fita de velcro/abraçadeira.
// Os rasgos de velcro existem em todas as versões, como reforço.
//
// MEÇA SEU TRIPÉ com paquímetro antes de imprimir.

/* [Fixação] */
fixacao = "argola";      // ["clip", "argola", "nenhum"]

/* [Clip - tubo redondo] */
diametro_tubo = 25;      // diâmetro da coluna central (mm) - MEDIR
altura_clip = 40;        // altura da abraçadeira
abertura_clip = 0.82;    // abertura da boca do clip, fração do diâmetro (menor = aperta mais)

/* [Argola - para mosquetão de verdade] */
diametro_argola = 18;    // diâmetro livre da argola (tem que passar o mosquetão) - MEDIR o mosquetão
espessura_argola = 4.5;  // "grossura" do material ao redor do furo da argola
largura_poste = 18;      // largura do poste (mm)
espessura_poste = 5;     // espessura do poste (mm) - ele fica em balanço, não deixe fino demais
margem_acima_bateria = 18; // quanto o centro da argola fica acima do topo do power bank

/* [Power bank - medidas oficiais 154 x 74 x 28 mm] */
pb_largura   = 74;
pb_espessura = 28;
pb_altura    = 154;
pb_raio      = 6;        // raio dos cantos arredondados
folga        = 0.8;      // folga por lado (PETG/PLA: 0.6 a 1.0)

/* [Berço] */
parede      = 2.4;
fundo       = 2.4;
altura_berco = 95;       // o power bank tem 154 mm: sobram ~60 mm para fora (portas e LEDs livres)
janela_larg = 46;        // janela frontal (mostra o logo e deixa empurrar para tirar)
janela_base = 14;
fixacao_z = altura_berco - 20; // altura do centro do clip na parede traseira (só usado por "clip")

$fn = 64;

iw = pb_largura + 2*folga;
it = pb_espessura + 2*folga;
ir = pb_raio + folga;
ow = iw + 2*parede;
ot = it + 2*parede;
orad = ir + parede;
ybk = it + parede;       // face traseira (externa) do berço
topo_pb = fundo + folga + pb_altura; // altura do topo do power bank, com o berço na origem

module rrect(w, t, r, h) {
    // retângulo arredondado centrado em X, de y=0 a y=t
    translate([0, t/2, 0]) linear_extrude(h)
        offset(r=r) square([w - 2*r, t - 2*r], center=true);
}

module berco() {
    difference() {
        translate([0, -parede, 0]) rrect(ow, ot, orad, altura_berco);
        translate([0, 0, fundo]) rrect(iw, it, ir, altura_berco);
        translate([-janela_larg/2, -parede - 1, janela_base])
            cube([janela_larg, parede + 2, altura_berco]);
        translate([0, it/2, -1]) linear_extrude(fundo + 2)
            offset(r=4) square([iw - 30, it - 16], center=true);
        for (z = [22, altura_berco - 22])
            for (s = [-1, 1])
                translate([s*(iw/2 - 12) - 2, it - 1, z - 13])
                    cube([4, parede + 2, 26]);
    }
}

// ---------- clip para tubo redondo (coluna central) ----------
module clip() {
    r_in  = diametro_tubo/2;
    esp   = 3.6;
    r_out = r_in + esp;
    boca  = diametro_tubo * abertura_clip;
    base  = 6;
    cy    = ybk + base + r_in;
    translate([0, 0, fixacao_z]) difference() {
        union() {
            translate([0, cy, 0]) rotate([-90, 0, 0]) cylinder(r=r_out, h=altura_clip, center=true);
            translate([-altura_clip/2, ybk - 0.5, -r_out])
                cube([altura_clip, base + r_in*0.6, r_out]);
        }
        translate([0, cy, 0]) rotate([-90, 0, 0]) cylinder(r=r_in, h=altura_clip + 2, center=true);
        translate([-boca/2, cy, -r_out - 1]) cube([boca, r_out + 2, r_out + 1]);
    }
}

// ---------- argola para mosquetão de verdade, acima do topo da bateria ----------
module argola() {
    r_furo = diametro_argola / 2;
    r_ext  = r_furo + espessura_argola;
    cz     = topo_pb + margem_acima_bateria + r_ext; // centro do furo da argola
    y0     = ybk - espessura_poste;                  // face de trás do poste

    // poste: liga o topo do berço até a base da argola
    translate([-largura_poste/2, y0, altura_berco])
        cube([largura_poste, espessura_poste, max(cz - r_ext - altura_berco, 0.1)]);

    // argola (disco com furo), eixo do furo na horizontal (X)
    translate([0, y0 + espessura_poste/2, cz])
        rotate([0, 90, 0])
        difference() {
            cylinder(r=r_ext, h=espessura_poste, center=true);
            cylinder(r=r_furo, h=espessura_poste + 2, center=true);
        }
}

color([1,0.55,0.1]) berco();
color([1,0.55,0.1]) if (fixacao == "clip") clip();
color([1,0.55,0.1]) if (fixacao == "argola") argola();
