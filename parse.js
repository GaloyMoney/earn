const {data} =require('./dist/output.json')

const result = data.reduce((acc, obj) => {
  const { contents, excerpt, id, answers: answersArr, ...rest } = obj;

  const chapter = id.match(/chapter-(.+)__.+/)[1];
  if (!acc[chapter]) {
    acc[chapter] = { title: '', questions: {} };
  }

  if (id.includes('README')) {
    acc[chapter].title = obj.title
    return acc;
  }

  const text = excerpt.replace(/<[^>]+>/g, '\n').replace(/\n+/g, '\n').trim();

  const questionId = id.match(/.+-lesson-(.+)/)[1];
  const answers = {};

  for (let i = 0; i < answersArr.length; i++) {
    answers[i] = answersArr[i];
  }
  acc[chapter].questions[questionId] = { ...rest, answers, text, type: 'Text' };

  return acc;
}, {});

console.log(JSON.stringify(result, null, 2));
