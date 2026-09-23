// Suporte para pendurar o power bank Xiaomi Mi 50W 20000mAh (PB2050SZM) em um tripé.
//
// O power bank fica em pé dentro de um "berço" aberto em cima (portas para cima)
// e o berço prende no tripé de uma destas formas (escolha em `fixacao`):
//   "clip"   - abraçadeira de encaixe (snap) para tubo redondo: coluna central do tripé.
//              Ele pode ficar apoiado em cima do anel onde se prendem as hastes/braços.
//   "gancho" - gancho em U invertido para pendurar numa haste, braço ou barra.
//   "nenhum" - só o berço, com rasgos para passar fita de velcro/abraçadeira.
// Os rasgos de velcro existem em todas as versões, como reforço.
//
// MEÇA SEU TRIPÉ com paquímetro e ajuste `diametro_tubo` / `vao_gancho` antes de imprimir.

/* [Fixação] */
fixacao = "clip";        // ["clip", "gancho", "nenhum"]
diametro_tubo = 25;      // diâmetro da coluna central (mm) - MEDIR
altura_clip = 40;        // altura da abraçadeira
abertura_clip = 0.82;    // abertura da boca do clip, fração do diâmetro (menor = aperta mais)
vao_gancho = 26;         // vão interno do gancho (largura da haste/barra onde pendura)
profundidade_gancho = 30;// quanto o gancho desce do lado de trás

/* [Power bank - medidas oficiais 154 x 74 x 28 mm] */
pb_largura   = 74;
pb_espessura = 28;
pb_raio      = 6;        // raio dos cantos arredondados
folga        = 0.8;      // folga por lado (PETG/PLA: 0.6 a 1.0)

/* [Berço] */
parede      = 2.4;
fundo       = 2.4;
altura_berco = 95;       // o power bank tem 154 mm: sobram ~60 mm para fora (portas e LEDs livres)
janela_larg = 46;        // janela frontal (mostra o logo e deixa empurrar para tirar)
janela_base = 14;

$fn = 64;

iw = pb_largura + 2*folga;
it = pb_espessura + 2*folga;
ir = pb_raio + folga;
ow = iw + 2*parede;
ot = it + 2*parede;
orad = ir + parede;

module rrect(w, t, r, h) {
    // retângulo arredondado centrado em X, de y=0 a y=t
    translate([0, t/2, 0]) linear_extrude(h)
        offset(r=r) square([w - 2*r, t - 2*r], center=true);
}

module berco() {
    difference() {
        translate([0, -parede, 0]) rrect(ow, ot, orad, altura_berco);
        // cavidade
        translate([0, 0, fundo]) rrect(iw, it, ir, altura_berco);
        // janela frontal em U, aberta em cima
        translate([-janela_larg/2, -parede - 1, janela_base])
            cube([janela_larg, parede + 2, altura_berco]);
        // furo no fundo: ventilação e para empurrar o power bank para cima
        translate([0, it/2, -1]) linear_extrude(fundo + 2)
            offset(r=4) square([iw - 30, it - 16], center=true);
        // rasgos para velcro na parede traseira (2 alturas)
        for (z = [22, altura_berco - 22])
            for (s = [-1, 1])
                translate([s*(iw/2 - 12) - 2, it - 1, z - 13])
                    cube([4, parede + 2, 26]);
    }
}

// ---------- clip para tubo redondo ----------
module clip() {
    r_in  = diametro_tubo/2;
    esp   = 3.6;
    r_out = r_in + esp;
    boca  = diametro_tubo * abertura_clip;
    base  = 6;                         // distância entre o berço e o tubo
    cy    = it + parede + base + r_in; // centro do tubo
    z0    = (altura_berco - altura_clip) / 2 + 10;
    translate([0, 0, z0]) {
        difference() {
            union() {
                translate([0, cy, 0]) cylinder(r=r_out, h=altura_clip);
                // pescoço que liga o anel ao berço
                translate([-(r_out*0.9), it + parede - 0.5, 0])
                    cube([2*r_out*0.9, base + r_in*0.5, altura_clip]);
            }
            translate([0, cy, -1]) cylinder(r=r_in, h=altura_clip + 2);
            // boca do clip (lado oposto ao berço)
            translate([-boca/2, cy, -1]) cube([boca, r_out + 2, altura_clip + 2]);
        }
    }
}

// ---------- gancho em U invertido ----------
module gancho() {
    larg = 34;       // largura do gancho (eixo X)
    e    = 5;        // espessura do perfil
    ztop = altura_berco + 8;         // altura do topo interno do gancho
    // perfil 2D em (Y, Z) extrudado ao longo de X
    translate([-larg/2, 0, 0]) rotate([90, 0, 90]) linear_extrude(larg) {
        // subida: prolonga a parede traseira acima do berço
        translate([it, altura_berco - 30]) square([e, ztop - altura_berco + 30 + e]);
        // topo (passa por cima da barra)
        translate([it, ztop]) square([vao_gancho + 2*e, e]);
        // aba que desce atrás da barra, com ponta arredondada
        translate([it + e + vao_gancho, ztop - profundidade_gancho]) square([e, profundidade_gancho + e]);
        translate([it + e + vao_gancho + e/2, ztop - profundidade_gancho]) circle(d=e);
    }
}

color([1,0.55,0.1]) berco();
color([1,0.55,0.1]) if (fixacao == "clip") clip();
color([1,0.55,0.1]) if (fixacao == "gancho") gancho();
