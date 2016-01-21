library saddle;

//import java.io.{ByteArrayInputStream, ByteArrayOutputStream, ObjectInputStream, ObjectOutputStream}

/**
 * utility methods for tests
 */
class Serde {
  /** provides a deep copy of this input object by serializing and deserializing it*/
  /*T*/ serializedCopy /*[T]*/ (T input) {
    val baos = new ByteArrayOutputStream();
    val oos = new ObjectOutputStream(baos);

    oos.writeObject(input);
    oos.close();

    val bais =
        new ObjectInputStream(new ByteArrayInputStream(baos.toByteArray));
    bais.readObject().asInstanceOf[T];
  }
}
