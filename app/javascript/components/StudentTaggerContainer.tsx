import React, { useState } from 'react';

import StudentTagger, { Student, Result } from './StudentTagger';

interface Props {
  student: Student;
}


export default (props: Props) => {
  const [student, setStudent ] = useState(props.student);
  const [result, setResult ] = useState<Result|undefined>(undefined);

  const assignToken = (tokenId: string, studentId: number) => {
    // TODO: wire up to backend
  }

  return <StudentTagger result={result} student={student} assignToken={assignToken} />
}

