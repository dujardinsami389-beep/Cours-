import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() => runApp(const CoursPlus());
class Lesson {
  final String level, subject, title, text, question;
  final List<String> choices;
  final int correct;
  const Lesson(this.level,this.subject,this.title,this.text,this.question,this.choices,this.correct);
}
const lessons = [
  Lesson('Primaire','Mathématiques','Les fractions','Une fraction représente une partie d’un tout. 1/4 + 2/4 = 3/4.','1/4 + 2/4 = ?', ['3/4','3/8','2/4'],0),
  Lesson('Primaire','Français','Sujet et verbe','Dans « Marie chante », Marie est le sujet et chante est le verbe.','Quel est le verbe ?', ['Marie','chante','aucun'],1),
  Lesson('Primaire','Histoire','Les grandes périodes','La Préhistoire précède l’Antiquité, puis viennent le Moyen Âge, les Temps modernes et l’époque contemporaine.','Quelle période précède l’Antiquité ?', ['Le Moyen Âge','La Préhistoire','Les Temps modernes'],1),
  Lesson('Collège','Mathématiques','Pythagore','Dans un triangle rectangle : a² + b² = c², avec c l’hypoténuse.','Hypoténuse pour 3 et 4 ?', ['5','6','7'],0),
  Lesson('Collège','Physique-chimie','Puissance électrique','P = U × I ; P en watts, U en volts et I en ampères.','12 V × 2 A = ?', ['6 W','14 W','24 W'],2),
  Lesson('Collège','SVT','La cellule','Une cellule possède une membrane et du cytoplasme ; de nombreuses cellules ont un noyau.','Qu’est-ce qui délimite la cellule ?', ['Membrane','Os','Racine'],0),
  Lesson('Collège','Histoire','La Révolution française','La prise de la Bastille a lieu le 14 juillet 1789.','En quelle année ?', ['1789','1815','1914'],0),
  Lesson('Lycée','Mathématiques','Dérivation','La dérivée de f(x) = x² est f’(x) = 2x.','Dérivée de x² ?', ['x','2x','x³'],1),
  Lesson('Lycée','Anglais','Present perfect','Le present perfect se forme avec have/has + participe passé.','Quelle phrase convient ?', ['I have eaten','I eat','I will eat'],0),
  Lesson('Lycée','Italien','Essere','Io sono, tu sei, lui è, noi siamo, voi siete, loro sono.','Nous sommes ?', ['Noi siamo','Voi siete','Io sono'],0),
  Lesson('Lycée','Philosophie','La liberté','La liberté peut être absence de contrainte ou autonomie dans les choix.','Que veut dire autonomie ?', ['Ne pas choisir','Se donner ses règles','Toujours obéir'],1),
];
class CoursPlus extends StatelessWidget {
  const CoursPlus({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title:'Cours+',debugShowCheckedModeBanner:false,
    theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:Colors.indigo),useMaterial3:true),
    home:const Home());
}
class Home extends StatefulWidget {
  const Home({super.key});
  @override State<Home> createState()=>_HomeState();
}
class _HomeState extends State<Home> {
  String level='Tous',subject='Toutes'; bool premium=false;
  Set<String> done={};
  @override void initState(){super.initState();load();}
  Future<void> load() async {
    final p=await SharedPreferences.getInstance();
    if(mounted)setState(() {premium=p.getBool('premium_demo')??false;done=(p.getStringList('done')??[]).toSet();});
  }
  Future<void> mark(String title) async {
    final p=await SharedPreferences.getInstance();
    setState(()=>done.add(title));await p.setStringList('done',done.toList());
  }
  Future<void> togglePremium() async {
    final p=await SharedPreferences.getInstance();
    setState(()=>premium=!premium);await p.setBool('premium_demo',premium);
  }
  @override Widget build(BuildContext context) {
    final filtered=lessons.where((x)=>(level=='Tous'||x.level==level)&&(subject=='Toutes'||x.subject==subject)).toList();
    final subjects=['Toutes',...{for(final x in lessons)x.subject}];
    return Scaffold(appBar:AppBar(title:const Text('Cours+ 🎓')),
      body:ListView(padding:const EdgeInsets.all(16),children:[
        Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          const Text('Apprends à ton rythme',style:TextStyle(fontSize:23,fontWeight:FontWeight.bold)),
          Text('Progression : ${done.length} / ${lessons.length} leçons'),
          LinearProgressIndicator(value:done.length/lessons.length),
          const SizedBox(height:12),
          Text(premium?'Premium démo activé':'Premium démo • 19,99 €/mois'),
          const Text('Mode démonstration : aucun paiement réel.'),
          FilledButton(onPressed:togglePremium,child:Text(premium?'Désactiver la démo Premium':'Activer la démo Premium'))
        ]))),
        DropdownButtonFormField<String>(value:level,decoration:const InputDecoration(labelText:'Niveau'),
          items:['Tous','Primaire','Collège','Lycée'].map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
          onChanged:(x)=>setState(()=>level=x!)),
        DropdownButtonFormField<String>(value:subject,decoration:const InputDecoration(labelText:'Matière'),
          items:subjects.map((x)=>DropdownMenuItem(value:x,child:Text(x))).toList(),
          onChanged:(x)=>setState(()=>subject=x!)),
        for(final lesson in filtered) Card(child:ListTile(
          title:Text(lesson.title),subtitle:Text('${lesson.level} • ${lesson.subject}'),
          trailing:Icon(done.contains(lesson.title)?Icons.check_circle:Icons.chevron_right),
          onTap:()=>Navigator.push(context,MaterialPageRoute(builder:(_)=>LessonPage(lesson:lesson,onComplete:()=>mark(lesson.title)))).then((_){if(mounted)setState((){});}),
        ))
      ]));
  }
}
class LessonPage extends StatefulWidget {
  final Lesson lesson; final Future<void> Function() onComplete;
  const LessonPage({super.key,required this.lesson,required this.onComplete});
  @override State<LessonPage> createState()=>_LessonPageState();
}
class _LessonPageState extends State<LessonPage> {
  int? answer;
  @override Widget build(BuildContext context) {
    final l=widget.lesson;
    return Scaffold(appBar:AppBar(title:Text(l.title)),body:ListView(padding:const EdgeInsets.all(20),children:[
      Text(l.text,style:const TextStyle(fontSize:18)),const SizedBox(height:25),
      Text(l.question,style:const TextStyle(fontSize:20,fontWeight:FontWeight.bold)),
      for(var i=0;i<l.choices.length;i++) RadioListTile<int>(title:Text(l.choices[i]),value:i,groupValue:answer,onChanged:(x)=>setState(()=>answer=x)),
      if(answer!=null) Text(answer==l.correct?'Bonne réponse !':'Réessaie.',style:TextStyle(color:answer==l.correct?Colors.green:Colors.red)),
      FilledButton(onPressed:answer==l.correct?()async{await widget.onComplete();if(context.mounted)Navigator.pop(context);}:null,child:const Text('Terminer la leçon'))
    ]));
  }
}
