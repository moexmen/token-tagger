import React, { useState } from 'react';

import StudentTagger, { Student, Result, FailureReasons } from './StudentTagger';

interface Props {
  csrfToken: string;
  student: Student;
}


export default (props: Props) => {
  const [student, setStudent ] = useState(props.student);
  const [result, setResult ] = useState<Result|undefined>(undefined);
  const [csrfToken, setCsrfToken] = useState(props.csrfToken);

  const [isFetching, setIsFetching] = useState(false);

  const assignToken = (tokenId: string, studentId: number) => {
    if (isFetching) {
      return;
    }

    setIsFetching(true);

    if (tokenId !== '') {
      setResult(null);
      
      fetch('/students/tag', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': csrfToken
        },
        body: JSON.stringify({ student_id: studentId, token_id: tokenId })
        }).then(resp => resp.json())
        .then(data => {
          setIsFetching(false);

          setResult(data.result);
          setStudent(data.next_student);
          setCsrfToken(data.csrf_token);
        }).catch(e => {
          setIsFetching(false);
          
          setResult({
            success: false,
            reason: FailureReasons.ApiError,
            student: student
          });
        });
    }
  }

  return <StudentTagger isFetching={isFetching} result={result} student={student} assignToken={assignToken} />
}

